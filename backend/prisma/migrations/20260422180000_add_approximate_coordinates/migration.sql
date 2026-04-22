-- Add approximate coordinates for street-level location masking
ALTER TABLE "games" ADD COLUMN "approximateLatitude" DOUBLE PRECISION;
ALTER TABLE "games" ADD COLUMN "approximateLongitude" DOUBLE PRECISION;
