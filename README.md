# AppsAndZerts
Display a list of desserts from .


## Dessert Feed Feature

### User Story - See all desserts
####  Narrative 1
```
As an online user
I want the app to automatically load desserts
So I can always see the latest available desserts
```

##### Scenario(s)

```
Given the user has internet connectivity
 When the user requests to see desserts
 Then the app should alphabetically display the latest desserts from the server
```

#### Narrative 2

```
As an offline user
I want the app to communicate that internet connection is unavailable
So that I know why I am unable to see a list of desserts
```

##### Scenario(s)

```
Given the user does not nave internet connectivity
 When the user requests to see desserts
 Then the app should an error message
```

### Use Case - Load Desserts From Server

##### Data
- URL: https://themealdb.com/api/json/v1/1/filter.php?c=Dessert

##### Happy Path
1. Execute "Load Desserts" using above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates dessert feed from valid data.
5. System delivers dessert feed.

##### Sad Path - Invalid data
1. System delivers invalid data error.

##### Sad Path - No connectivity
1. System delivers connectivity error.


## Dessert Details Feature

### User Story - Dessert Details

####  Narrative 1
```
As an online user
I want the app to display the details of a selected desserts
So I can learn more about the selected dessert
```

##### Scenario(s)

```
Given the user has internet connectivity
 When the user selects a dessert
 Then the app should display a detail view for that dessert containing it's meal name, instructions, ingredients/measurements.
```

#### Narrative 2

```
As an offline user
I want the app to communicate that internet connection is unavailable
So that I know why I am unable to see the details of a selected dessert
```

##### Scenario(s)

```
Given the user does not nave internet connectivity
 When the user selects a dessert
 Then the app should display an error message
```

### Use Case - Load Dessert Details From Server

##### Data
- MEAL_ID
- URL: https://themealdb.com/api/json/v1/1/lookup.php?i=MEAL_ID


##### Happy path
1. Execute "Load Dessert Details" using above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates dessert feed from valid data.
5. System delivers dessert feed.

##### Sad Path - Invalid data
1. System delivers invalid data error.

##### Sad Path - No connectivity
1. System delivers connectivity error.
