using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.ActivityMonitor;
using Toybox.UserProfile;

class TwoByThreeDataFieldView extends WatchUi.DataField {

    hidden var mvtl;
    hidden var mvtr;
    hidden var mvml;
    hidden var mvmr;
    hidden var mvbl;
    hidden var mvbr;

	hidden var m_heart_rate_zones;
//	hidden var m_power_zones;

    hidden var m_heart_rate_color;

    function initialize() {
        DataField.initialize();

        var sport = UserProfile.getCurrentSport();
		m_heart_rate_zones = UserProfile.getHeartRateZones(sport);
 		m_heart_rate_color = [
				Graphics.COLOR_DK_GRAY, 
				Graphics.COLOR_BLUE,
				Graphics.COLOR_GREEN,
				Graphics.COLOR_ORANGE,
				Graphics.COLOR_RED,
				Graphics.COLOR_DK_RED];

        mvtl = "00:00:00";
        mvtr = 0.0f;
        mvml = 0.0f;
        mvmr = 0;
        mvbl = 0f;
        mvbr = 0;
        
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();
    	var width = dc.getWidth();
    	var height = dc.getHeight();
		if (width < 240 or height < 240)
		{
            View.setLayout(Rez.Layouts.SingleValueLayout(dc));
			View.findDrawableById("label").setLocation(width/2, height/2-20);
        } else
        {
            View.setLayout(Rez.Layouts.MainLayout(dc));
        }		
        return true;
    }

    function compute(info) {
        if(info has :currentHeartRate){
            if(info.currentHeartRate != null){
                mvbr = info.currentHeartRate;
            } else {
                mvbr = 0;
            }
        }
        if(info has :currentSpeed){
            if(info.currentSpeed != null){
                mvml = 3.6 * info.currentSpeed;
            } else {
         
                mvml = 0;
            }
        }
        if(info has :currentPower){
            if(info.currentPower != null){
                mvbl = info.currentPower;
            } else {
                mvbl = 0;
            }
        }
        if(info has :currentCadence){
            if(info.currentCadence != null){
                mvmr = info.currentCadence;
            } else {
                mvmr = 0;
            }
        }
        if(info has :elapsedDistance){
            if(info.elapsedDistance != null){
                mvtr = info.elapsedDistance / 1000.0;
            } else {
                mvtr = 0;
            }
        }
        if(info has :timerTime){
            if(info.timerTime != null){
                var totalseconds = (info.timerTime/1000.0).toLong();
                var seconds = totalseconds % 60;
                var minutes = ((totalseconds / 60) % 60).toLong();
                var hours = ((totalseconds / 3600) % 3600).toLong();
                mvtl = Lang.format("$1$:$2$:$3$", ["00", minutes.format("%02d"), seconds.format("%02d")]);
            } else {
                mvtl = 0;
            }
        }
    }

	function setElement(name, value, color)
	{
		var v = View.findDrawableById(name);
        v.setColor(color);
		v.setText(value);
	}

	function setTime(name, use24)
	{
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var ispm = false;
        if (!System.getDeviceSettings().is24Hour and !use24) {
        	ispm = (hours > 12);
            if (ispm) {
                hours = hours - 12;
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
        if (ispm) {
        	timeString += "p";
        }
        View.findDrawableById(name).setText(timeString);
	}

	function setBattery(name)
	{
        var battery = System.getSystemStats().battery;
		var bv = View.findDrawableById(name);
        if (battery < 10.0)
        {
        	bv.setColor(Graphics.COLOR_RED);
        }
        else if (battery < 30.0)
        {
        	bv.setColor(Graphics.COLOR_YELLOW);
        }
        else
        {
        	bv.setColor(Graphics.COLOR_GREEN);
        }
        bv.setText(Lang.format("$1$%", [battery.format("%4.1f")]));
	}

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        var bg_color = getBackgroundColor();
        View.findDrawableById("Background").setColor(bg_color);
		var fg_color = Graphics.COLOR_WHITE;
        if (bg_color == Graphics.COLOR_WHITE)
        {
            fg_color = Graphics.COLOR_BLACK;
		}

    	var width = dc.getWidth();
    	var height = dc.getHeight();
		if (width < 240 or height < 240)
		{
			var w = (width/2).toLong();
			var h = (height/2).toLong();
			View.findDrawableById("label").setLocation(w, h-35);
			var value = View.findDrawableById("value");
			value.setLocation(w, h-5);
			value.setText(mvml.format("%5.1f"));
			value.setColor(fg_color);
		} else        {
			setTime("time", true);
			setBattery("battery");
			setElement("vtl", mvtl, fg_color);
			setElement("vtr", mvtr.format("%5.2f"), fg_color);
			setElement("vml", mvml.format("%5.1f"), fg_color);
			setElement("vmr", mvmr.format("%3d"), fg_color);
			setElement("vbl", mvbl.format("%5.0f"), fg_color);
			
			var i = 0;
			var hrt_color = fg_color;
			var size = m_heart_rate_zones.size();
			while (i <= size-1 and mvbr>m_heart_rate_zones[i]){
				hrt_color = m_heart_rate_color[i];
//				System.println(i.format("%3d"));
				i += 1;
			}
//			System.println("Setting heart rate color");
			setElement("vbr", mvbr.format("%3d"), hrt_color);
		}
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
