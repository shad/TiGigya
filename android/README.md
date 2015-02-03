Android Manifest Requirement
========

You will need to add this to your android manifest in tiapp.xml

	<activity
		android:name="com.gigya.socialize.android.login.providers.WebLoginActivity"
		android:theme="@android:style/Theme.Translucent.NoTitleBar"
		android:launchMode="singleTask" android:allowTaskReparenting="true">
		<intent-filter>
			<action android:name="android.intent.action.VIEW" />
			<category android:name="android.intent.category.DEFAULT" />
			<category android:name="android.intent.category.BROWSABLE" />
			<data android:scheme="YOUR_APP_ACTIVITY_NAME" android:host="gsapi" />
		</intent-filter>
	</activity>

Note that you will need to replace "YOUR_APP_ACTIVITY_NAME" with the activity name for your app, typically something like ".AppNameActivity". You can always find the activity name in build/android/AndroidManifest.xml
