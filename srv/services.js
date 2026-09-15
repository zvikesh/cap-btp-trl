import cds from '@sap/cds'

export class ProcessorService extends cds.ApplicationService {
  init() {

    const { Incidents } = this.entities

    // Reject changing status of a closed incident
    this.before('UPDATE', Incidents, async req => {
      const closed = await SELECT.one(1).from(req.subject).where`status.code = 'C'`
      if (closed) req.reject`Can't modify a closed incident!`
    })

    // Flag incidents as urgent if their title contains the word 'urgent'
    this.before(['CREATE', 'UPDATE'], Incidents, req => {
      const urgent = req.data.title?.match(/urgent/i)
      if (urgent) req.data.urgency_code = 'H'
    })

    return super.init()
  }
}
