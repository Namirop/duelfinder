-- AlterTable
ALTER TABLE "users" ADD COLUMN     "hiddenConversations" TEXT[] DEFAULT ARRAY[]::TEXT[];
