/**
 * Notification Types
 */

export interface NotificationPayload {
    title: string;
    body: string;
    data?: Record<string, string>;
}

export interface OrderNotificationData {
    orderId: string;
    totalPrice: number;
    customerName: string;
    itemCount: number;
}

export interface OrderStatusNotificationData {
    orderId: string;
    status: string;
    userId: string;
}
