// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define('schedulePushNotification', function (request, response) {

   var alarmObjectId = request.params.alarmObjectId;

    var getAlarmPromiseFromObjectId = function (alarmId) {

        var alarmQuery = new Parse.Query('Alarm');

        alarmQuery.equalTo('objectId', alarmId);

        return alarmQuery.first();
    };

    var getAlarmRolesFromAlarm = function (alarm) {

        var roleQuery = new Parse.Query('UserAlarmRole');

        roleQuery.equalTo('alarm', alarm);

        return roleQuery.find();
    };

    // returns unfetched pointers
    var getUsersFromRoles = function (roles) {

        var users = roles.map( function (roles) {
            return roles.get('user');
        });

        return users;
    };

    var schedulePushNotificationToUsers = function (users, alarm, bools) {

        var dateToSent = alarm.get('alarmTime');
        var labelToSent = alarm.get('alarmLabel');
		
        var query = new Parse.Query(Parse.Installation);
        query.containedIn('user', users);

        // var boolquery = new Parse.Query('UserAlarmRole');
        // boolquery.equalTo('alarmActivated', bools);
        return Parse.Push.send({
            where: query,
            data: {
                alert: labelToSent,
				sound: 'sound.m4a',
				time: alarm
            },
            push_time: dateToSent,
        });
    };

    getAlarmPromiseFromObjectId(alarmObjectId).then( function (alarm) {

        getAlarmRolesFromAlarm(alarm).then( function (roles) {

            roles = roles.filter( function (role) {
                return role.get('alarmActivated');
            });

            var users = getUsersFromRoles(roles);

            schedulePushNotificationToUsers(users, alarm).then( function () {
                // push was successfull
                response.success("successfully sent push");
            }, function (error) {
                // push got fucked up
                response.error("error, fuck.");
            });

        });

    });

});