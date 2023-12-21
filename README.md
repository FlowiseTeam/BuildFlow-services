# BuildFlow-services
Repository contains all BuildFlow backend microservices 

## Installation
To install project, you can follow these steps:
1. Clone this repository to your local machine using `git clone https://github.com/FlowiseTeam/BuildFlow-services.git`
2. Install the required dependencies by running `bundle install` 
3. Start the app by running `rails s` for projects-services or `rails s -p 3001` for employees-services

## Technologies Used
    - Ruby
    - Rails
    - Python
    - Mongo DB

## Services List
1. projects-service
2. emplooyes-service
3. vehicles-services

## Project Structure
```
├───projects-service
    ├───app
    |   ├───controllers
    |   |   └───api
    |   |       ├───comments_controller.rb //comments controller
    |   |       ├───projects_controller.rb //projects controller
    |   |       ├───employees_assignments_controller.rb //employees_assignments controller
    |   |       └───vehicles_assignments_controller.rb //vehicles_assignments controller
    |   └───models
    |       ├───comment.rb //comments models
    |       ├───project.rb //project models
    |       ├───vehicle_assignments.rb //vehicle models
    |       └───employee_assignments.rb //employee models
    ├───config
    |    └───routes.rb //projects and assignments routes for api
    └───spec
        ├───factories
        |    └───project.rb //model for tests
        └───controllers
            ├───api
            └──────projects_controller_spec.rb  //tests methods   

├───employees-service
    ├───app
    |   ├───controllers
    |   |   └───api
    |   |       └───employees_controller.rb //employee controller
    |   └───models
    |       └───employee.rb //employee models
    ├───config
    |    └───routes.rb //employees routes for api
    └───spec
        ├───factories
        |    └───employees.rb //model for tests
        └───controllers
            ├───api
            └──────employees_controller_spec.rb //tests methods
            
├───vehicles-service
    ├───app
    |   ├───controllers
    |   |   └───api
    |   |       └───vehicles_controller.rb //vehicles controller
    |   └───models
    |       └───vehicle.rb //vehicle models
    ├───config
    |    └───routes.rb //vehicles routes for api
    └───spec
        ├───factories
        |    └───vehicles.rb //model for tests
        └───controllers
            ├───api
            └──────vehicles_controller_spec.rb //tests methods     
```
