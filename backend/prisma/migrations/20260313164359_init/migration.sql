-- AlterEnum
ALTER TYPE "NotificationType" ADD VALUE 'PARTICIPATION_CANCELLED';

-- AlterTable
ALTER TABLE "participations" ADD COLUMN     "lastReadAt" TIMESTAMP(3);
