/**
 * GET /api/v1/admin/users/:id
 * PATCH /api/v1/admin/users/:id
 * DELETE /api/v1/admin/users/:id
 */

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/middleware/admin.middleware";
import {
	errorHandler,
	NotFoundError,
	ValidationError,
} from "@/middleware/error.middleware";
import { ApiResponse } from "@/types/global";
import { prisma } from "@/lib/prisma";
import {
	validateEmail,
	validatePhone,
	sanitizeString,
} from "@/utils/validators";
import { hashPassword } from "@/utils/helpers";
import { UserRole } from "@/types/global";

function toUserResponse(user: any) {
	return {
		id: user.id,
		name: user.name,
		email: user.email,
		phone: user.phone,
		role: user.role,
		isActive: user.isActive,
		createdAt: user.createdAt.toISOString(),
		updatedAt: user.updatedAt.toISOString(),
	};
}

export const GET = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const user = await prisma.user.findUnique({ where: { id: params.id } });
		if (!user) throw new NotFoundError("User");

		const response: ApiResponse<ReturnType<typeof toUserResponse>> = {
			success: true,
			data: toUserResponse(user),
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const PATCH = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const body = await request.json();

		const data: {
			name?: string;
			email?: string;
			phone?: string;
			role?: UserRole;
			isActive?: boolean;
			passwordHash?: string;
		} = {};

		if (body.name !== undefined) {
			const name = sanitizeString(String(body.name));
			if (name.length < 2)
				throw new ValidationError("Name is too short", "name");
			data.name = name;
		}

		if (body.email !== undefined) {
			const email = String(body.email).toLowerCase().trim();
			if (!validateEmail(email))
				throw new ValidationError("Invalid email", "email");
			data.email = email;
		}

		if (body.phone !== undefined) {
			const phone = String(body.phone).trim();
			if (!validatePhone(phone))
				throw new ValidationError("Invalid phone", "phone");
			data.phone = phone;
		}

		if (body.role !== undefined) {
			if (body.role !== "ADMIN" && body.role !== "CUSTOMER") {
				throw new ValidationError("Invalid role", "role");
			}
			data.role = body.role;
		}

		if (body.isActive !== undefined) {
			if (typeof body.isActive !== "boolean") {
				throw new ValidationError("isActive must be boolean", "isActive");
			}
			data.isActive = body.isActive;
		}

		if (body.password !== undefined) {
			if (typeof body.password !== "string" || body.password.length < 8) {
				throw new ValidationError(
					"Password must be at least 8 characters",
					"password",
				);
			}
			data.passwordHash = await hashPassword(body.password);
		}

		const updated = await prisma.user.update({
			where: { id: params.id },
			data,
		});

		const response: ApiResponse<ReturnType<typeof toUserResponse>> = {
			success: true,
			data: toUserResponse(updated),
			message: "User updated successfully",
		};

		return NextResponse.json(response, { status: 200 });
	},
);

export const DELETE = errorHandler(
	async (request: NextRequest, { params }: { params: { id: string } }) => {
		const adminResult = await requireAdmin(request);
		if (!adminResult.authorized) return adminResult.response;

		const user = await prisma.user.findUnique({ where: { id: params.id } });
		if (!user) throw new NotFoundError("User");

		const updated = await prisma.user.update({
			where: { id: params.id },
			data: { isActive: false },
		});

		const response: ApiResponse<ReturnType<typeof toUserResponse>> = {
			success: true,
			data: toUserResponse(updated),
			message: "User deactivated successfully",
		};

		return NextResponse.json(response, { status: 200 });
	},
);
