# database-systems-project-website

## Project Website

Triggers:

When Individual Order is updated, update Transaction + Complete Order Summary

When Transaction is updated, if that transaction is within an event, add to money made within event

When transaction tips are updated, add to associated employee's total tips

Procedures/Functions:

After the day is over, collects key order times (last breakfast order, fried chicken sold out) for that day

After an event is over, calculate what the most popular item was (use name)

## To Run on Local Server:

**MAKE SURE YOU PUT YOUR ROOT PASSWORD IN THE DATABASE.PY FOR MYSQL, OTHERWISE THE APPLICATION WILL NOT WORK**

First, create a virtual environment in your project folder and activate it.

On Mac:

```powershell
python -m venv venv
source venv/bin/activate
```

On Windows:

```powershell
python -m venv venv
source .venv/Scripts/activate
```

Then, install all required libraries with the following command in your VSCode terminal:

```
pip install -r requirements.txt
```

To run the app, run the following command:

```powershell
uvicorn main:app
```
