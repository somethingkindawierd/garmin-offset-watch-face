using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Application as App;
using Toybox.ActivityMonitor as ActivityMonitor;

class OffsetWatchFaceView extends Ui.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Get the current time and format it correctly
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        if (!Sys.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (App.getApp().getProperty("UseMilitaryFormat")) {
                hours = hours.format("%02d");
            }
        }
        
        // Update the view
        var hourLabel = View.findDrawableById("HourLabel");
        var minuteLabel = View.findDrawableById("MinuteLabel");
        
        var hourText = Lang.format("$1$", [hours]);
        var minuteText = Lang.format("$1$", [clockTime.min.format("%02d")]);

        hourLabel.setColor(App.getApp().getProperty("ForegroundColor"));
        hourLabel.setText(hourText);

        minuteLabel.setColor(App.getApp().getProperty("ForegroundColor"));
        minuteLabel.setText(minuteText);
        
        var level = View.findDrawableById("level");
        level.setPercent(getStepsPercent());

        var level2 = View.findDrawableById("level2");
        level2.setPercent(getBatteryPercent());

        var level3 = View.findDrawableById("level3");
        level3.setPercent(getMoveBarLevel());

		var moment = Time.now();
		var info = Gregorian.info(moment, Time.FORMAT_SHORT);
		var dateString = Lang.format("$1$-$2$", [
			info.month.format("%02d"),
			info.day.format("%02d")
		]);
		Sys.println(dateString);
		var dateLabel = View.findDrawableById("Date");
		dateLabel.setText(dateString);

		Sys.println(-Sys.getClockTime().timeZoneOffset);
		var uctMoment = moment.add(new Time.Duration(-Sys.getClockTime().timeZoneOffset));
		var utcInfo = Gregorian.info(uctMoment, Time.FORMAT_SHORT);
		var utcString = Lang.format("$1$:$2$", [
		    utcInfo.hour.format("%02d"),
			utcInfo.min.format("%02d")
		]);
		Sys.println(utcString);
		var utcLabel = View.findDrawableById("UTCTime");
		utcLabel.setText(utcString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
       
		// Draw the line that separates the two halves.
		var line = new Rez.Drawables.DividingLine();
		line.draw( dc );
		
		/*
		var moveBar = new ProgressBar({
			:locX=>10,
			:locY=>10,
			:width=>50,
			:height=>50,
			:color=>Gfx.COLOR_ORANGE
		});
		moveBar.setPercent(0.5);
		moveBar.draw( dc );
		*/
    }
    
    hidden function getBatteryPercent() {
    	var stats = Sys.getSystemStats();
    	var battery = stats.battery;
    	return battery / 100;
    }
    
    hidden function getStepsPercent() {
    	var info = ActivityMonitor.getInfo();
    	var stepsGoal = info.stepGoal;
    	var steps = info.steps;
    	return steps / stepsGoal;
    }
    
    hidden function getMoveBarLevel() {
    	var info = ActivityMonitor.getInfo();
    	var level = info.moveBarLevel;
    	if (level < ActivityMonitor.MOVE_BAR_LEVEL_MIN) {
    		return 0;
    	}
    	else {
    		return level / ActivityMonitor.MOVE_BAR_LEVEL_MAX;
    	}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
