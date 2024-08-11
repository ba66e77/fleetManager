# Fleet Management Tool

**version:** 0.1.1

## Version history
  - 0.1.1 Converted to use db in Mother Duck cloud service.
  - 0.1 Mileage management to track gas milage for a vehicle, storing data in local duckdb file.

## Roadmap  

### future features
  - support multivehicle tracking
  - add trend of overstatement across time to see if the numbers converge
    - look at correlation to see if there's more subtle trend in the number
  - add API readings of odometer and fuel percent and see how those correlate to measured values
   
### implementation details
   [x] cloud hosted db
   - reporting UI
     - streamlit
   - import of data by reading image files (visual and metadata)
   - convert sql file to data pipeline
   - automate image capture
     - remove image from library after upload
   - DevEx tooling
