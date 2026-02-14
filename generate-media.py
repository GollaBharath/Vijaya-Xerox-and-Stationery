#!/usr/bin/env python3
"""
Generate sample product images and PDFs for testing
"""
import os
from pathlib import Path
import sys

def generate_images():
    """Generate sample images using PIL"""
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("⚠ PIL not installed, using minimal solution")
        return False
    
    images_dir = Path("/home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/uploads/images/products")
    images_dir.mkdir(parents=True, exist_ok=True)
    
    products = [
        ("product-4.jpg", "Pharmacology\nTextbook", "#FF6B6B"),
        ("product-5.jpg", "Pathology\nGuide", "#4ECDC4"),
        ("product-6.jpg", "Notebook\nA4", "#FFE66D"),
        ("product-7.jpg", "Blue Pens\nPack", "#95E1D3"),
        ("product-8.jpg", "Gel Pens\nSet", "#F38181"),
        ("product-9.jpg", "Markers\nColors", "#AA96DA"),
        ("product-10.jpg", "Sticky\nNotes", "#FCBAD3"),
        ("product-11.jpg", "Clinical\nAnatomy", "#A8D8EA"),
    ]
    
    for filename, text, color in products:
        filepath = images_dir / filename
        if filepath.exists():
            print(f"✓ {filename} already exists")
            continue
        
        try:
            # Create image
            img = Image.new('RGB', (400, 500), color=color)
            draw = ImageDraw.Draw(img)
            
            # Add text
            try:
                font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 40)
            except:
                font = ImageFont.load_default()
            
            # Draw text in center
            bbox = draw.textbbox((0, 0), text, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
            x = (400 - text_width) // 2
            y = (500 - text_height) // 2
            
            draw.text((x, y), text, fill="white", font=font)
            
            # Save
            img.save(filepath, quality=85)
            print(f"✓ Generated: {filename}")
        except Exception as e:
            print(f"✗ Failed to generate {filename}: {e}")
            return False
    
    return True

def generate_sample_pdf():
    """Generate sample PDF files"""
    try:
        from reportlab.pdfgen import canvas
        from reportlab.lib.pagesizes import letter
    except ImportError:
        print("⚠ reportlab not installed, creating minimal PDFs")
        return False
    
    pdfs_dir = Path("/home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/uploads/pdfs/books")
    pdfs_dir.mkdir(parents=True, exist_ok=True)
    
    pdf_titles = [
        "anatomy-guide.pdf",
        "physiology-notes.pdf", 
        "biochemistry-manual.pdf",
        "pharmacology-reference.pdf",
        "pathology-guide.pdf",
    ]
    
    for pdf_name in pdf_titles:
        filepath = pdfs_dir / pdf_name
        if filepath.exists():
            print(f"✓ {pdf_name} already exists")
            continue
        
        try:
            c = canvas.Canvas(str(filepath), pagesize=letter)
            c.drawString(100, 750, f"Medical Reference: {pdf_name}")
            c.drawString(100, 730, "Sample PDF Document")
            c.drawString(100, 710, "Generated for testing purposes")
            c.showPage()
            c.save()
            print(f"✓ Generated: {pdf_name}")
        except Exception as e:
            print(f"✗ Failed to generate {pdf_name}: {e}")
            return False
    
    return True

if __name__ == "__main__":
    print("📸 Generating sample product images and PDFs...\n")
    
    generate_images()
    generate_sample_pdf()
    
    print("\n✅ Media generation complete!")
