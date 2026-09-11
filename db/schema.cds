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
namespace sap.capire.incidents;

/**
 * Incidents created by customers.
 *
 * Each incident tracks its customer, title, urgency, status, and a conversation
 * history composed of individual messages.
*/
entity Incidents : cuid, managed {
    customer     : Association to Customers;
    title        : String @title: 'Title';
    urgency      : Association to Urgency default 'M';
    status       : Association to Status default 'N';
    conversation : Composition of many {
                       key ID        : UUID;
                           timestamp : type of managed : createdAt;
                           author    : type of managed : createdBy;
                           message   : String;
                   };
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
        /**
         * Convenience name derived from first and last name.
         */
        name         : String = trim(firstName || ' ' || lastName);
        email        : EMailAddress;
        phone        : PhoneNumber;
        incidents    : Association to many Incidents
                           on incidents.customer = $self;
        creditCardNo : String(16) @assert.format: '^[1-9]\d{15}$';
        addresses    : Composition of many Addresses
                           on addresses.customer = $self;
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
