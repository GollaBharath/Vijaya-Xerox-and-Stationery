/**
 * Subjects Module Type Definitions
 */

export interface Subject {
	id: string;
	name: string;
	categoryId: string;
	parentSubjectId: string | null;
	createdAt: string;
	updatedAt: string;
	children?: Subject[];
}

export interface SubjectTreeResponse {
	subjects: Subject[];
}
