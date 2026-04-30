# database-systems-project-website

## Project Website

Triggers:

When Individual Order is updated, update Transaction + Complete Order Summary
When Transaction is updated, if that transaction is within an event, add to money made within event
When transaction tips are updated, add to associated employee's total tips

Procedures/Functions:

After the day is over, collects key order times (last breakfast order, fried chicken sold out) for that day
After an event is over, calculate what the most popular item was (use name)
