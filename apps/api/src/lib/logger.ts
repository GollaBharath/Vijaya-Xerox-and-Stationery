/**
 * Simple Logger Utility
 *
 * Provides structured logging with different levels
 */

type LogLevel = "info" | "warn" | "error" | "debug";

interface LogOptions {
	timestamp?: boolean;
	context?: string;
}

class Logger {
	private static formatMessage(
		level: LogLevel,
		message: string,
		data?: any,
		options?: LogOptions,
	): string {
		const timestamp =
			options?.timestamp !== false ? new Date().toISOString() : "";
		const context = options?.context ? `[${options.context}]` : "";
		const dataStr = data ? `\n${JSON.stringify(data, null, 2)}` : "";

		return `${timestamp} [${level.toUpperCase()}] ${context} ${message}${dataStr}`;
	}

	public static info(message: string, data?: any, options?: LogOptions): void {
		console.log(this.formatMessage("info", message, data, options));
	}

	public static warn(message: string, data?: any, options?: LogOptions): void {
		console.warn(this.formatMessage("warn", message, data, options));
	}

	public static error(
		message: string,
		error?: any,
		options?: LogOptions,
	): void {
		const errorData =
			error instanceof Error
				? { message: error.message, stack: error.stack }
				: error;
		console.error(this.formatMessage("error", message, errorData, options));
	}

	public static debug(message: string, data?: any, options?: LogOptions): void {
		if (process.env.NODE_ENV === "development") {
			console.debug(this.formatMessage("debug", message, data, options));
		}
	}

	// Request logging helper
	public static request(
		method: string,
		path: string,
		statusCode?: number,
		duration?: number,
	): void {
		const message = `${method} ${path}${statusCode ? ` - ${statusCode}` : ""}${duration ? ` (${duration}ms)` : ""}`;
		this.info(message, undefined, { context: "HTTP" });
	}
}

export const logger = Logger;
