echo "Stopping CCD"
docker ps --filter "ancestor=rcpu/lof-services:ccdservice" -q | xargs -r docker stop
echo ""
echo "Stopping AOService"
docker ps --filter "ancestor=rcpu/lof-services:aoservice" -q | xargs -r docker stop
echo ""
echo "Stopping FHIRService"
docker ps --filter "ancestor=hapiproject/hapi:latest" -q | xargs -r docker stop
echo ""
echo "Stopping AODB"
docker ps --filter "ancestor=postgres:16" -q | xargs -r docker stop
echo ""
echo "Clearing Docker Service Cache"
docker system prune -f