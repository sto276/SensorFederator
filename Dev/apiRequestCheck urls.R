



# bbox outside Australia
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, longitude='bob', latitude=-26, bbox='-56;144;-15;150', numToReturn=NULL)

# bbox malformed
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, longitude='bob', latitude=-26, bbox='-56;144;-15;bob', numToReturn=NULL)


# location outside Australia
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, longitude=150, latitude=-56, numToReturn=NULL)


# NULLlatitude
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, longitude='bob', latitude=NULL, numToReturn=NULL)

# invalid latitude
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, longitude=150, latitude='bob', numToReturn=NULL)

# invalid search Radius
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, longitude=150, latitude=-26, radius_km='bob', numToReturn=NULL)

# invalid number of records to return
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, longitude=150, latitude=-26, radius_km=100, numToReturn='bob')

# invalid Sensor Type
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype='bob', longitude=150, latitude=-26, radius_km=100, numToReturn=1)






#No error - no spatial filter
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, numToReturn=NULL)

#No error - well formed point query
apiGetSensorLocations(usr='Public', pwd='Public', siteid=NULL, sensortype=NULL, longitude=150, latitude=-26, radius_km=2, numToReturn=NULL)

#No error - well formed bbox query
apiGetSensorLocations(usr='Public', pwd='Public', bbox='-26;144;-15;150')


check_GetSensorLocations(siteid=NULL, sensortype='bob', longitude=150, latitude=-26, radius_km=1, numToReturn=NULL)
