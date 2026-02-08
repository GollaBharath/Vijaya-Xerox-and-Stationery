#!/bin/bash

# Fly.io Deployment Script for Vijaya Bookstore API
# This script automates the deployment process to Fly.io

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$PROJECT_DIR/apps/api"
APP_NAME="vijaya-api"
REGION="sin"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if flyctl is installed
check_flyctl() {
    if ! command -v flyctl &> /dev/null && ! command -v fly &> /dev/null; then
        print_error "Fly CLI is not installed. Please install it first:"
        echo "https://fly.io/docs/getting-started/installing-flyctl/"
        exit 1
    fi
    print_success "Fly CLI is installed"
}

# Check authentication
check_auth() {
    print_info "Checking Fly.io authentication..."
    if ! flyctl auth whoami &> /dev/null; then
        print_error "Not authenticated with Fly.io"
        print_info "Run: flyctl auth login"
        exit 1
    fi
    ACCOUNT=$(flyctl auth whoami)
    print_success "Authenticated as: $ACCOUNT"
}

# Check payment method
check_payment() {
    print_warning "Ensure you have a payment method on file in Fly.io dashboard"
    print_info "Visit: https://fly.io/dashboard/personal/billing"
    read -p "Press enter once payment method is added..."
}

# Validate environment variables
validate_env() {
    print_header "Validating Environment Variables"
    
    cd "$API_DIR"
    
    # Check if .env exists
    if [ ! -f .env ]; then
        print_error ".env file not found in $API_DIR"
        exit 1
    fi
    
    print_success ".env file found"
    
    # Check critical variables
    source .env 2>/dev/null || true
    
    if [ -z "$DATABASE_URL" ]; then
        print_error "DATABASE_URL is not set in .env"
        print_info "Required format: postgresql://user:password@host:port/database"
        exit 1
    fi
    print_success "DATABASE_URL is set"
    
    if [ -z "$REDIS_URL" ]; then
        print_error "REDIS_URL is not set in .env"
        print_info "Use Upstash Redis: rediss://default:password@endpoint.upstash.io:6379"
        exit 1
    fi
    print_success "REDIS_URL is set"
    
    if [ -z "$JWT_SECRET" ]; then
        print_error "JWT_SECRET is not set in .env"
        exit 1
    fi
    print_success "JWT_SECRET is set"
}

# Setup app
setup_app() {
    print_header "Setting Up Fly App"
    
    cd "$API_DIR"
    
    # Check if app exists
    if flyctl status -a "$APP_NAME" &> /dev/null; then
        print_success "App '$APP_NAME' already exists"
    else
        print_info "App '$APP_NAME' does not exist. Creating..."
        
        if ! flyctl launch --name "$APP_NAME" --region "$REGION" --no-deploy 2>&1 | grep -q "Error"; then
            print_success "App created successfully"
        else
            print_error "Failed to create app"
            exit 1
        fi
    fi
}

# Set secrets
set_secrets() {
    print_header "Setting Secrets on Fly.io"
    
    cd "$API_DIR"
    source .env 2>/dev/null || true
    
    print_info "Setting DATABASE_URL..."
    flyctl secrets set -a "$APP_NAME" DATABASE_URL="$DATABASE_URL"
    print_success "DATABASE_URL set"
    
    print_info "Setting REDIS_URL..."
    flyctl secrets set -a "$APP_NAME" REDIS_URL="$REDIS_URL"
    print_success "REDIS_URL set"
    
    print_info "Setting JWT_SECRET..."
    flyctl secrets set -a "$APP_NAME" JWT_SECRET="$JWT_SECRET"
    print_success "JWT_SECRET set"
    
    if [ -n "$JWT_REFRESH_SECRET" ]; then
        print_info "Setting JWT_REFRESH_SECRET..."
        flyctl secrets set -a "$APP_NAME" JWT_REFRESH_SECRET="$JWT_REFRESH_SECRET"
        print_success "JWT_REFRESH_SECRET set"
    fi
    
    if [ -n "$API_BASE_URL" ]; then
        print_info "Setting API_BASE_URL..."
        flyctl secrets set -a "$APP_NAME" API_BASE_URL="$API_BASE_URL"
        print_success "API_BASE_URL set"
    fi
    
    if [ -n "$CORS_ORIGINS" ]; then
        print_info "Setting CORS_ORIGINS..."
        flyctl secrets set -a "$APP_NAME" CORS_ORIGINS="$CORS_ORIGINS"
        print_success "CORS_ORIGINS set"
    fi
    
    if [ -n "$RAZORPAY_KEY_ID" ]; then
        print_info "Setting Razorpay secrets..."
        flyctl secrets set -a "$APP_NAME" \
            RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID" \
            RAZORPAY_KEY_SECRET="$RAZORPAY_KEY_SECRET" \
            RAZORPAY_WEBHOOK_SECRET="$RAZORPAY_WEBHOOK_SECRET"
        print_success "Razorpay secrets set"
    fi
}

# Deploy
deploy() {
    print_header "Deploying to Fly.io"
    
    cd "$API_DIR"
    
    print_info "Building and deploying Docker image..."
    if flyctl deploy -a "$APP_NAME" --strategy rolling; then
        print_success "Deployment successful"
    else
        print_error "Deployment failed"
        exit 1
    fi
}

# Run migrations
run_migrations() {
    print_header "Running Database Migrations"
    
    print_info "Connecting to remote machine..."
    print_info "Running: npx prisma migrate deploy"
    
    if flyctl ssh console -a "$APP_NAME" -C "cd /app && npx prisma migrate deploy && npx prisma generate"; then
        print_success "Migrations completed successfully"
    else
        print_warning "Migrations may have failed or been skipped"
        print_info "You can manually run migrations later with:"
        echo "flyctl ssh console -a $APP_NAME"
        echo "cd /app && npx prisma migrate deploy"
    fi
}

# Verify deployment
verify_deployment() {
    print_header "Verifying Deployment"
    
    print_info "Waiting for app to be ready..."
    sleep 10
    
    APP_URL=$(flyctl info -a "$APP_NAME" --json 2>/dev/null | grep -o '"hostname":"[^"]*' | cut -d'"' -f4 || echo "")
    
    if [ -n "$APP_URL" ]; then
        print_success "App URL: https://$APP_URL"
        
        print_info "Testing health endpoint..."
        if curl -s "https://$APP_URL/api/health" > /dev/null 2>&1; then
            print_success "Health check passed"
        else
            print_warning "Health check failed (app may still be starting)"
        fi
    else
        print_warning "Could not determine app URL"
        print_info "Check status with: flyctl status -a $APP_NAME"
    fi
    
    print_header "Deployment Complete"
    print_success "Your API is now deployed on Fly.io!"
    
    if [ -n "$APP_URL" ]; then
        print_info "API Base URL: https://$APP_URL"
        print_info "Admin Panel: https://$APP_URL/admin"
    fi
}

# Main execution
main() {
    print_header "Vijaya Bookstore - Fly.io Deployment"
    
    check_flyctl
    check_auth
    check_payment
    validate_env
    setup_app
    set_secrets
    deploy
    run_migrations
    verify_deployment
}

# Run main function
main "$@"
