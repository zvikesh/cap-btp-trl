using {
    cuid,
    managed,
    sap.common.CodeList
} from '@sap/cds/common';

/**
 * Common CDS features used throughout this model.
 * `cuid` adds a unique identifier and `managed` adds administrative fields such as
 * `createdAt` and `createdBy`.
 */
namespace sap.capire.incidents; //To avoid name conflict with another db microservice

/**
 * Incidents created by customers.
 *
 * Each incident tracks its customer, title, urgency, status, and a conversation
 * history composed of individual messages.
*/
entity Incidents : cuid, managed {
    title        : String @title: 'Title';
    /* Associations */
    customer     : Association to Customers;
    urgency      : Association to Urgency default 'M';
    status       : Association to Status default 'N';
    /* Compositions */
    conversation : Composition of many Conversations
                       on conversation.incident = $self;
}

/**
 * Customers entitled to create support incidents.
 *
 * The `name` element is a calculated element that combines `firstName` and
 * `lastName` for convenience.
*/
entity Customers : managed {
    key ID           : String;
        firstName    : String;
        lastName     : String;
        name         : String = trim(firstName || ' ' || lastName); //Convenience name derived from first and last name.
        email        : EMailAddress;
        phone        : PhoneNumber;
        creditCardNo : String(16) @assert.format: '^[1-9]\d{15}$';
        /* Associations */
        incidents: Association to many Incidents
                           on incidents.customer = $self;
        /* Compositions */
        addresses    : Composition of many Addresses
                           on addresses.customer = $self;
}

/**
 * Conversation messages belonging to incidents.
 */
entity Conversations : managed {
    key ID      : UUID;
    incident    : Association to Incidents;
    timestamp   : type of managed : createdAt;
    author      : type of managed : createdBy;
    message     : String;
}

/**
 * Addresses belonging to customers.
 */
entity Addresses : cuid, managed {
    customer      : Association to Customers;
    city          : String;
    postCode      : String;
    streetAddress : String;
}

/**
 * Status values for incidents.
 */
entity Status : CodeList {
    key code        : String enum {
            new = 'N';
            assigned = 'A';
            in_process = 'I';
            on_hold = 'H';
            resolved = 'R';
            closed = 'C';
        };
        criticality : Integer;
}

/**
 * Urgency values for incidents.
 */
entity Urgency : CodeList {
    key code : String enum {
            high = 'H';
            medium = 'M';
            low = 'L';
        };
}

/**
 * Email address type alias.
 */
type EMailAddress : String;

/**
 * Phone number type alias.
 */
type PhoneNumber  : String;
