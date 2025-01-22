import json

from fhirclient import client
from fhirclient.models.condition import Condition

settings = {
    'app_id': 'HAPI FHIR R4 Server',
    'api_base': 'http://127.0.0.1:8080/fhir'
}

p_id = '3678'

smart = client.FHIRClient(settings=settings)

query = {'subject': 'Patient/3678', 'category': 'problem-list-item', '_sort': '-_lastUpdated', '_count': '1000', 'clinical-status': 'http://terminology.hl7.org/CodeSystem/condition-clinical|Active'}

try:
    bundle = Condition.where(query).perform(smart.server)
    conditions = [be.resource.as_json() for be in bundle.entry] if bundle and bundle.entry else []
    print(json.dumps(conditions))
except Exception as e:
    print(f"Failed to fetch condition data for patient {p_id}: {e}")
