/**
 * Subjects Repository
 */

import { prisma } from "@/lib/prisma";
import { Subject } from "./subjects.types";

function toSubject(entity: any): Subject {
	return {
		id: entity.id,
		name: entity.name,
		parentSubjectId: entity.parentSubjectId ?? null,
		createdAt: entity.createdAt.toISOString(),
		updatedAt: entity.updatedAt.toISOString(),
	};
}

export async function findSubjectById(id: string): Promise<Subject | null> {
	const subject = await prisma.subject.findUnique({
		where: { id },
	});
	return subject ? toSubject(subject) : null;
}

export async function findAllSubjects(): Promise<Subject[]> {
	const subjects = await prisma.subject.findMany({
		orderBy: { createdAt: "desc" },
	});
	return subjects.map(toSubject);
}

export async function createSubject(
	name: string,
	parentSubjectId: string | null,
): Promise<Subject> {
	const subject = await prisma.subject.create({
		data: {
			name,
			parentSubjectId: parentSubjectId ?? null,
		},
	});

	return toSubject(subject);
}

export async function updateSubject(
	id: string,
	data: { name?: string; parentSubjectId?: string | null },
): Promise<Subject> {
	const subject = await prisma.subject.update({
		where: { id },
		data: {
			name: data.name,
			parentSubjectId: data.parentSubjectId,
		},
	});

	return toSubject(subject);
}

export async function deleteSubject(id: string): Promise<Subject> {
	const subject = await prisma.subject.delete({
		where: { id },
	});
	return toSubject(subject);
}

export async function getSubjectTree(): Promise<Subject[]> {
	const subjects = await prisma.subject.findMany({
		orderBy: { createdAt: "asc" },
	});

	const map = new Map<string, Subject>();
	const roots: Subject[] = [];

	subjects.forEach((s) => {
		map.set(s.id, {
			...toSubject(s),
			children: [],
		});
	});

	map.forEach((subject) => {
		if (subject.parentSubjectId && map.has(subject.parentSubjectId)) {
			map.get(subject.parentSubjectId)?.children?.push(subject);
		} else {
			roots.push(subject);
		}
	});

	return roots;
}
