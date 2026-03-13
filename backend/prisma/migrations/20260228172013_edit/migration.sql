/*
  Warnings:

  - The values [IN_PROGRESS,COMPLETED] on the enum `GameStatus` will be removed. If these variants are still used in the database, this will fail.

*/
-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'PARTNER', 'ADMIN');

-- CreateEnum
CREATE TYPE "BadgeLevel" AS ENUM ('BRONZE', 'SILVER', 'GOLD');

-- AlterEnum
BEGIN;
CREATE TYPE "GameStatus_new" AS ENUM ('OPEN', 'FULL', 'CANCELLED');
ALTER TABLE "games" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "games" ALTER COLUMN "status" TYPE "GameStatus_new" USING ("status"::text::"GameStatus_new");
ALTER TYPE "GameStatus" RENAME TO "GameStatus_old";
ALTER TYPE "GameStatus_new" RENAME TO "GameStatus";
DROP TYPE "GameStatus_old";
ALTER TABLE "games" ALTER COLUMN "status" SET DEFAULT 'OPEN';
COMMIT;

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "NotificationType" ADD VALUE 'GAME_CANCELLED';
ALTER TYPE "NotificationType" ADD VALUE 'GAME_FULL';

-- AlterTable
ALTER TABLE "games" ADD COLUMN     "finishedAt" TIMESTAMP(3),
ADD COLUMN     "wasFilledOnce" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "participations" ADD COLUMN     "acceptedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "badgeLevel" "BadgeLevel",
ADD COLUMN     "bio" TEXT,
ADD COLUMN     "role" "UserRole" NOT NULL DEFAULT 'USER',
ADD COLUMN     "totalGamesPlayed" INTEGER NOT NULL DEFAULT 0;
