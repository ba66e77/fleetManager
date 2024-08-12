/*****
 * FILE
 * 
 * Faux-pipeline for ingesting and initial processing of data.
 * 
 *****/


/**
 * Attach to MotherDuck and make sure we have a database to write to.
 *
 */
attach 'md:';
create database if not exists fleet_management;
use fleet_management;

/**
 * Read raw vehicle data into a table.
 * 
 * columns
 *  - vehicle_id -- unique identifier of the vehicle; currently using tag number
 *  - make
 *  - model
 *  - year
 *
 * @todo
 *  - handle unregistered vehicles or vehicles where a state has the same tag number as another state; maybe also international vehicles, someday?
 *  - add trim identifier, as different trim packages have different base milage
 *  - maybe add base milage expected from manufacturer?
 */
create or replace table vehicles
  as (
    select *
    from read_csv('/Users/barrett/Desktop/elantraMileage/vehicles.csv')
  );

/**
 * Read the raw source data into a table.
 *
 * columns
 *  - vehicle_id -- unique identifier of the vehicle; should be part of primary key
 *  - record_date datetime -- datetime on which readings were taken; should be part of primary key
 *  - odometer_mileage integer -- total miles recorded on the odometer
 *  - refill_gallons float -- how many gallons were added to fill the tank
 *  - trip_mileage float -- the trip meter or since-refill meter, measuring distance traveled since last refill
 *  - computer_mpg float -- the avg MPG as reported on the trip or since-refill meter
 *  - notes text -- anything of note about the reading, which might impact analytics
 *
 */
create or replace table refill_data
  as (
    select *
    replace (strptime(record_date, '%Y-%m-%d %H:%M')  as record_date) -- cast record_date into a datetime
    from read_csv('/Users/barrett/Desktop/elantraMileage/refill_readings.csv')
  );


/**
 * Add calculated values for the reckoned mpg and the variance between mpg readings.
 *
 */
create or replace table refill_calculations
  as (
    select 
      refill_data.*,
      round(
        (trip_mileage / refill_gallons)
        , 3
      ) as reckoned_mpg, -- a dead reackoned value of `trip_milage / refill_gallons` rounded to 3
      round(
        computer_mpg - reckoned_mpg
        , 3
      ) as computer_mpg_overstatement, -- a reckoned value of `computer_mpg - reckoned_mpg`, to keep track of how many more miles the computer says were traveled than the calculated value; negative would mean reckoned was greater than computer 
      round(
        avg(computer_mpg_overstatement)
        over(
          partition by "vehicle_id"
          order by record_date asc
          rows between 2 preceding and 0 following
        )
        , 3
      ) as r3_overstatement_average, -- a rolling 3 observation average value of computer_mpg_overstatement
      round(
        computer_mpg_overstatement - r3_overstatement_average
        , 3
      ) as variance_from_r3 -- a raw difference of this reading from the r3 average, to help visualize trends
    from refill_data
  );
