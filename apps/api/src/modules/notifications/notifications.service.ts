/**
 * Notifications Service
 */

import * as admin from "firebase-admin";
import { prisma } from "@/lib/prisma";
import { logger } from "@/lib/logger";
import { initializeFirebaseAdmin } from "@/lib/firebase-admin";
import { NotificationPayload, OrderNotificationData } from "./notifications.types";
import { UserRole } from "@prisma/client";

/**
 * Get FCM tokens for all active admin users
 */
async function getAdminFcmTokens(): Promise<string[]> {
    const admins = await prisma.user.findMany({
        where: {
            role: UserRole.ADMIN,
            isActive: true,
            fcmToken: {
                not: null,
            },
        },
        select: {
            fcmToken: true,
        },
    });

    return admins
        .map((admin) => admin.fcmToken)
        .filter((token): token is string => token !== null);
}

/**
 * Send notification to multiple FCM tokens
 */
async function sendMulticastNotification(
    tokens: string[],
    payload: NotificationPayload,
): Promise<void> {
    if (tokens.length === 0) {
        logger.warn("No FCM tokens to send notifications to");
        return;
    }

    // Initialize Firebase Admin if not already done
    initializeFirebaseAdmin();

    const message: admin.messaging.MulticastMessage = {
        notification: {
            title: payload.title,
            body: payload.body,
        },
        data: payload.data,
        tokens: tokens,
    };

    try {
        const response = await admin.messaging().sendEachForMulticast(message);

        logger.info("Multicast notification sent", {
            successCount: response.successCount,
            failureCount: response.failureCount,
        });

        // Log individual failures
        if (response.failureCount > 0) {
            response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                    logger.error("Failed to send notification to token", {
                        token: tokens[idx].substring(0, 20) + "...",
                        error: resp.error?.message,
                    });
                }
            });
        }
    } catch (error: any) {
        logger.error("Failed to send multicast notification", {
            error: error?.message,
        });
        throw error;
    }
}

/**
 * Send order notification to all admin users
 */
export async function sendOrderNotificationToAdmins(
    orderData: OrderNotificationData,
): Promise<void> {
    try {
        const tokens = await getAdminFcmTokens();

        if (tokens.length === 0) {
            logger.info("No admin FCM tokens available, skipping notification");
            return;
        }

        const payload: NotificationPayload = {
            title: "New Order Received! 🛒",
            body: `${orderData.customerName} placed an order for ₹${orderData.totalPrice.toFixed(2)} (${orderData.itemCount} items)`,
            data: {
                type: "new_order",
                orderId: orderData.orderId,
                totalPrice: orderData.totalPrice.toString(),
                customerName: orderData.customerName,
                itemCount: orderData.itemCount.toString(),
            },
        };

        await sendMulticastNotification(tokens, payload);

        logger.info("Order notification sent to admins", {
            orderId: orderData.orderId,
            adminCount: tokens.length,
        });
    } catch (error: any) {
        // Log error but don't throw - notification failure shouldn't block order creation
        logger.error("Failed to send order notification to admins", {
            orderId: orderData.orderId,
            error: error?.message,
        });
    }
}
