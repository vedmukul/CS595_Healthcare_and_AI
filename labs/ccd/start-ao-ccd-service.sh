./stop-ao-ccd-service.sh
#Run PgSQL
echo ""
echo ""
echo "Starting AODB"
docker run -d \
	--add-host=host.docker.internal:host-gateway \
	--platform linux/amd64 \
	--network=bridge \
	--name aodb \
	-p 5432:5432 \
	-v $(pwd)/postgres_data:/var/lib/postgresql/data \
	-e POSTGRES_USER=postgres \
	-e POSTGRES_PASSWORD=admin123 \
	-e POSTGRES_HOST_AUTH_METHOD=trust \
	postgres:16

#Run HAPI-FHIR
echo ""
echo "Starting FHIRService"
cd fhir
docker run -d \
	--add-host=host.docker.internal:host-gateway \
	--platform linux/amd64 \
	--network=bridge \
	--name fhirservice \
	-p 8080:8080 \
	-v $(pwd):/configs \
	-e "--spring.config.location=file:///configs/application.yaml" \
	hapiproject/hapi:latest
cd ..

#Run AOService
echo ""
echo "Starting AOService"
docker run -d \
	--add-host=host.docker.internal:host-gateway \
	--platform linux/amd64 \
	--network=bridge \
	--name aoservice \
    -e lof_service_client_id="8yhvjONcccxghdsuojgEuVy2e3y_2Wkn2yV9Kvrdc1c" \
    -e lof_service_client_secret="tsUKgfwFPtMkwmoYlu51eTtp0Qko_nO0bTSw-O-uiKbJ5nWE_GR4I3m_bTk8fLiq" \
    -e POSTGRES_HOST="172.17.0.1" \
    -e POSTGRES_PORT="5432" \
    -e POSTGRES_DB="aodb" \
    -e POSTGRES_USER="postgres" \
    -e POSTGRES_PASSWORD="admin123" \
    -e HAPI_FHIR_URL="http://172.17.0.1:8080" \
    -e lof_auth_url="https://auth.leapoffaith.com" \
    -e lof_service_url="https://api.leapoffaith.com" \
	-p 8000:8000 \
	rcpu/lof-services:aoservice \
	/start

sleep 10
#Run CCD
echo ""
echo "Starting CCD"
docker run -d \
	--add-host=host.docker.internal:host-gateway \
	--platform linux/amd64 \
	--network=bridge \
	--name ccdservice \
	-e client_id="8yhvjONcccxghdsuojgEuVy2e3y_2Wkn2yV9Kvrdc1c" \
    -e client_secret="tsUKgfwFPtMkwmoYlu51eTtp0Qko_nO0bTSw-O-uiKbJ5nWE_GR4I3m_bTk8fLiq" \
    -e BASE_URL=http://127.0.0.1:8000/api/ \
	-p 4200:80 \
	rcpu/lof-services:ccdservice

#List services
echo ""
echo "Services Running"
docker ps