/**
 * Category Repository
 */

import { prisma } from "@/lib/prisma";
import { Prisma } from "@prisma/client";
import { Category } from "./catalog.types";

function toCategory(entity: any): Category {
	return {
		id: entity.id,
		name: entity.name,
		parentId: entity.parentId ?? null,
		metadata: entity.metadata ?? null,
		isActive: entity.isActive,
		createdAt: entity.createdAt.toISOString(),
		updatedAt: entity.updatedAt.toISOString(),
	};
}

export async function findCategoryById(id: string): Promise<Category | null> {
	const category = await prisma.category.findUnique({
		where: { id },
	});
	return category ? toCategory(category) : null;
}

export async function findAllCategories(
	isActive?: boolean,
): Promise<Category[]> {
	const categories = await prisma.category.findMany({
		where: isActive === undefined ? undefined : { isActive },
		orderBy: { createdAt: "desc" },
	});

	return categories.map(toCategory);
}

export async function createCategory(
	name: string,
	parentId: string | null,
	metadata: Record<string, unknown> | null,
): Promise<Category> {
	const category = await prisma.category.create({
		data: {
			name,
			parentId: parentId ?? null,
			metadata: (metadata ?? undefined) as Prisma.InputJsonValue | undefined,
		},
	});

	return toCategory(category);
}

export async function updateCategory(
	id: string,
	data: {
		name?: string;
		parentId?: string | null;
		metadata?: Record<string, unknown> | null;
		isActive?: boolean;
	},
): Promise<Category> {
	const category = await prisma.category.update({
		where: { id },
		data: {
			name: data.name,
			parentId: data.parentId,
			metadata: (data.metadata ?? undefined) as
				| Prisma.InputJsonValue
				| undefined,
			isActive: data.isActive,
		},
	});

	return toCategory(category);
}

export async function deleteCategory(id: string): Promise<Category> {
	// Find all direct children of this category
	const children = await prisma.category.findMany({
		where: {
			parentId: id,
			isActive: true,
		},
	});

	// Recursively delete all children first
	for (const child of children) {
		await deleteCategory(child.id);
	}

	// Now delete the parent category (soft delete)
	const category = await prisma.category.update({
		where: { id },
		data: { isActive: false },
	});

	return toCategory(category);
}

export async function getCategoryTree(): Promise<Category[]> {
	const categories = await prisma.category.findMany({
		where: { isActive: true },
		orderBy: { createdAt: "asc" },
	});

	const map = new Map<string, Category>();
	const roots: Category[] = [];

	categories.forEach((c) => {
		map.set(c.id, {
			...toCategory(c),
			children: [],
		});
	});

	map.forEach((category) => {
		if (category.parentId && map.has(category.parentId)) {
			map.get(category.parentId)?.children?.push(category);
		} else {
			roots.push(category);
		}
	});

	return roots;
}
