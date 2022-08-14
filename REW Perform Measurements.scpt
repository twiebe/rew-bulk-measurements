-- LICENSE
-- Copyright (c) 2022 Thomas Wiebe
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice, this
--   list of conditions and the following disclaimer.
--
-- * Redistributions in binary form must reproduce the above copyright notice,
--   this list of conditions and the following disclaimer in the documentation
--   and/or other materials provided with the distribution.
--
-- * The names of contributors may not be used to endorse or promote products derived from
--   this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- DESCRIPTION
-- This script is a poor man's automation for performing measurments in bulk with the absolutely gorgeous
-- Room EQ Wizard (REW), which is kindly made available for free by John Mulcahy. (can't thank you enough, John!)
--
-- It triggers measurements for the `channels` defined below sequentially in REW.
-- It will wait `measurement_duration` between measurements, so the
-- delay needs to accomodate for a complete measurement duration.

-- USAGE
-- - Set `channels` to the channels you wish to measure. Measurements are performed in the order given here.
-- - Set `measurement_duration` to the expected measurement duration, including the timing reference.
-- - Open the Measurement screen in REW manually once and make sure all settings other than channel and
--   measurement name match your requirements.
-- - Run this script
-- - When asked, enter the suffix to be appended to measurement names.
-- - Wait for measurements to be performed. You can abort and redo measurements after each run.

-- NOTE
-- The script is based on keystrokes. I've found that under certain circumstances, field numbers are different.
-- This mostly affects testing w/o attached mic. If this affects you, you might need to change tab-repetitions.
--
-- Tested with REW v5.20.9
--

-- CONFIGURATION
set channels to {"L", "R", "C", "LFE", "SL", "SR"}
set measurement_duration to 20

-- SCRIPT
set suffix to display dialog "Suffix for measurement naming" default answer ""

tell application "System Events"
	repeat with channel in channels
		set measurement_ok to false
		repeat while measurement_ok is false
			display dialog "Continue with channel " & channel buttons {"Continue", "Abort"} default button "Continue"
			if the button returned of the result is "Abort" then
				return
			end if
			tell application "REW" to activate
			delay 0.2

			-- make sure we're on the main window of REW
			repeat 4 times
				key code 53 -- esc
				delay 0.05
			end repeat

			-- open measurement dialog
			keystroke "m" using command down
			delay 0.2

			-- navigate to measurement name
			repeat 4 times
				keystroke {tab}
				delay 0.05
			end repeat

			-- enter measurement name with suffix
			keystroke channel
			if text returned of suffix is not "" then
				keystroke " " & text returned of suffix
			end if

			-- navigate to channel dropdown
			repeat 16 times -- 14 w/o mic attached, 16 with
				keystroke {tab} using shift down
				delay 0.05
			end repeat

			-- select channel from dropdown
			-- navigate to latest entry in dropdown first, to increase
			-- chances of finding the right channel via keystrokes
			repeat 20 times
				key code 125 -- downarrow
				delay 0.02
			end repeat
			key code 36 -- return
			keystroke channel

			-- navigate to start button
			repeat 12 times -- 10 w/o mic attached, 12 with
				keystroke {tab}
				delay 0.05
			end repeat

			-- press start button
			key code 49 -- space
			delay measurement_duration

			-- exit measurement screen
			key code 53 -- esc

			-- if you still see the measurement screen at this point, your `measurement_duration`
			-- might be too short or something went wrong with the measurement.

			-- need to redo the measurement?
			display dialog "Measurement for channel " & channel & " okay?" buttons {"Yes", "No"} default button "Yes"
			if the button returned of the result is "Yes" then
				set measurement_ok to true
			end if
		end repeat
	end repeat
end tell
