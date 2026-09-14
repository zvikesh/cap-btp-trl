using {sap.capire.incidents as my} from '../db/schema';

/**
 * Service used by support personell, i.e. the incidents' 'processors'.
 */
service ProcessorService {
    @odata.draft.enabled
    entity Incidents as projection on my.Incidents;
    @readonly
    entity Customers as projection on my.Customers;
}

/**
 * Service used by administrators to manage customers and incidents.
 */
service AdminService {
    @odata.draft.enabled
    entity Customers as projection on my.Customers;
    @odata.draft.enabled
    entity Incidents as projection on my.Incidents;
}