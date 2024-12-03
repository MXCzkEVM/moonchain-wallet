package com.appinio.socialshare.appinio_social_share.utils;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.provider.Telephony;

import androidx.core.content.FileProvider;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareHashtag;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.ShareDialog;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class SocialShareUtil {
    public static final String ERROR_APP_NOT_AVAILABLE = "ERROR_APP_NOT_AVAILABLE";
    public static final String ERROR_CANCELLED = "error : cancelled";
    public static final String UNKNOWN_ERROR = "unknown error";
    public static final String SUCCESS = "SUCCESS";

    //packages
    private final String INSTAGRAM_PACKAGE = "com.instagram.android";
    private final String TWITTER_PACKAGE = "com.twitter.android";
    private final String INSTAGRAM_STORY_PACKAGE = "com.instagram.share.ADD_TO_STORY";
    private final String INSTAGRAM_FEED_PACKAGE = "com.instagram.share.ADD_TO_FEED";
    private final String WHATSAPP_PACKAGE = "com.whatsapp";
    private final String WE_CHAT_PACKAGE = "com.tencent.mm";
    private final String TELEGRAM_PACKAGE = "org.telegram.messenger";
    private final String TELEGRAM_WEB_PACKAGE = "org.telegram.messenger.web";
    private final String TIKTOK_PACKAGE = "com.zhiliaoapp.musically";
    private final String FACEBOOK_STORY_PACKAGE = "com.facebook.stories.ADD_TO_STORY";
    private final String FACEBOOK_PACKAGE = "com.facebook.katana";
    private final String FACEBOOK_LITE_PACKAGE = "com.facebook.lite";
    private final String FACEBOOK_MESSENGER_PACKAGE = "com.facebook.orca";
    private final String FACEBOOK_MESSENGER_LITE_PACKAGE = "com.facebook.mlite";
    private final String SMS_DEFAULT_APPLICATION = "sms_default_application";


    private static CallbackManager callbackManager;


    public String shareToWhatsApp(String imagePath, String msg, Context context) {
        return shareFileAndTextToPackage(imagePath, msg, context, WHATSAPP_PACKAGE);
    }

    public String shareToWhatsAppFiles(ArrayList<String> imagePaths, Context context) {
        return shareFilesToPackage(imagePaths, context, WHATSAPP_PACKAGE);
    }

    public String shareToWeChat(String filePath, String title, Context activity) {
        return shareFileAndTextToPackage(filePath, title, activity, WE_CHAT_PACKAGE);
    }

    public String shareToInstagramDirect(String text, Context activity) {
        return shareTextToPackage(text, activity, INSTAGRAM_PACKAGE);
    }

    public String shareToInstagramFeed(String imagePath, String message, Context activity, String text) {
        return shareFileAndTextToPackage(imagePath, text, activity, INSTAGRAM_PACKAGE);
    }

    public String shareToInstagramFeedFiles(ArrayList<String> imagePaths, Context activity, String text) {
        return shareFilesToPackage(imagePaths, activity, INSTAGRAM_PACKAGE);
    }

    public String shareToTikTok(ArrayList<String> imagePaths, Context activity) {
        return shareFilesToPackage(imagePaths, activity, TIKTOK_PACKAGE);
    }

    public String shareToTwitter(String imagePath, Context activity, String text) {
        return shareFileAndTextToPackage(imagePath, text, activity, TWITTER_PACKAGE);
    }

    public String shareToTwitterFiles(ArrayList<String> imagePaths, Context activity) {
        return shareFilesToPackage(imagePaths, activity, TWITTER_PACKAGE);
    }

    public String shareToTelegram(String imagePath, Context activity, String text) {
        // Trying to launch Telegram downloaded from Google play
        String result = shareFileAndTextToPackage(imagePath, text, activity, TELEGRAM_PACKAGE);

        // Trying to launch Telegram downloaded from Web
        if (!result.equals(SUCCESS)) {
            result = shareFileAndTextToPackage(imagePath, text, activity, TELEGRAM_WEB_PACKAGE);
        }

        return result;
    }

    public String shareToTelegramFiles(ArrayList<String> imagePaths, Context activity) {
        // Trying to launch Telegram downloaded from Google Play
        String result = shareFilesToPackage(imagePaths, activity, TELEGRAM_PACKAGE);

        // Trying to launch Telegram downloaded from It's website
        if (!result.equals(SUCCESS)) {
            result = shareFilesToPackage(imagePaths, activity, TELEGRAM_WEB_PACKAGE);
        }

        return result;
    }


    public String shareToMessenger(String text, Context activity) {
        Map<String, Boolean> apps = getInstalledApps(activity);
        String packageName;
        if (apps.get("messenger")) {
            packageName = FACEBOOK_MESSENGER_PACKAGE;
        } else if (apps.get("messenger-lite")) {
            packageName = FACEBOOK_MESSENGER_LITE_PACKAGE;
        } else {
            return ERROR_APP_NOT_AVAILABLE;
        }
        return shareTextToPackage(text, activity, packageName);
    }


    public String copyToClipBoard(String content, Context activity) {
        try {
            ClipboardManager clipboard = (ClipboardManager) activity.getSystemService(Context.CLIPBOARD_SERVICE);
            ClipData clip = ClipData.newPlainText("", content);
            clipboard.setPrimaryClip(clip);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }

    public String shareToSMS(String content, Context activity, String imagePath) {
        String defaultApplication;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            defaultApplication = Telephony.Sms.getDefaultSmsPackage(activity);
        } else {
            defaultApplication = Settings.Secure.getString(activity.getContentResolver(), SMS_DEFAULT_APPLICATION);
        }
        return shareFileAndTextToPackage(imagePath, content, activity, defaultApplication);
    }
    public String shareToSMSFiles( Context activity, ArrayList<String> imagePaths) {
        String defaultApplication;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            defaultApplication = Telephony.Sms.getDefaultSmsPackage(activity);
        } else {
            defaultApplication = Settings.Secure.getString(activity.getContentResolver(), SMS_DEFAULT_APPLICATION);
        }
        return shareFilesToPackage(imagePaths, activity, defaultApplication);
    }


    public String shareToSystemFiles(String title, ArrayList<String> filePaths, String chooserTitle, Context activity) {
        try {
            if (filePaths == null || filePaths.isEmpty()) return "No files to share";
            Intent intent = new Intent();
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setAction(Intent.ACTION_SEND_MULTIPLE);
            ArrayList<Uri> files = new ArrayList<Uri>();
            for (int i = 0; i < filePaths.size(); i++) {
                Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(filePaths.get(i)));
                files.add(fileUri);
            }
            intent.setType(getMimeTypeOfFile(filePaths.get(0)));
            intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, files);
            intent.putExtra(Intent.EXTRA_SUBJECT, title);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            Intent chooserIntent = Intent.createChooser(intent, chooserTitle);
            chooserIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activity.startActivity(chooserIntent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }


    public String shareToSystem(String title, String message, String filePath, String chooserTitle, Context activity) {
        try {
            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setAction(Intent.ACTION_SEND);
            if (filePath != null) {
                Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(filePath));
                intent.setType(getMimeTypeOfFile(filePath));
                intent.putExtra(Intent.EXTRA_STREAM, fileUri);
            } else {
                intent.setType("text/plain");
            }

            intent.putExtra(Intent.EXTRA_TEXT, message);
            intent.putExtra(Intent.EXTRA_SUBJECT, title);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            Intent chooserIntent = Intent.createChooser(intent, chooserTitle);
            chooserIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            chooserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activity.startActivity(chooserIntent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }


    public String shareToInstagramStory(String appId, String stickerImage, String backgroundImage, String backgroundTopColor, String backgroundBottomColor, String attributionURL, Context activity) {

        try {

            Intent shareIntent = new Intent(INSTAGRAM_STORY_PACKAGE);
            shareIntent.setType("image/*");
            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            if (stickerImage != null) {
                File file = new File(stickerImage);
                Uri stickerImageUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", file);
                shareIntent.putExtra("interactive_asset_uri", stickerImageUri);
                activity.grantUriPermission("com.instagram.android", stickerImageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            if (backgroundImage != null) {
                File file1 = new File(backgroundImage);
                Uri backgroundImageUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", file1);
                shareIntent.setDataAndType(backgroundImageUri, getMimeTypeOfFile(backgroundImage));
                activity.grantUriPermission("com.instagram.android", backgroundImageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            shareIntent.putExtra("source_application", appId);
            shareIntent.putExtra("content_url", attributionURL);
            shareIntent.putExtra("top_background_color", backgroundTopColor);
            shareIntent.putExtra("bottom_background_color", backgroundBottomColor);
            activity.startActivity(shareIntent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }

    }


    public void shareToFacebook(List<String> filePaths, String text, Activity activity, MethodChannel.Result result) {
        FacebookSdk.fullyInitialize();
        FacebookSdk.setApplicationId(getFacebookAppId(activity));
        callbackManager = callbackManager == null ? CallbackManager.Factory.create() : callbackManager;
        ShareDialog shareDialog = new ShareDialog(activity);
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result1) {
                System.out.println("---------------onSuccess");
                result.success(SUCCESS);
            }

            @Override
            public void onCancel() {
                result.success(ERROR_CANCELLED);
            }

            @Override
            public void onError(FacebookException error) {
                System.out.println("---------------onError");
                result.success(error.getLocalizedMessage());
            }
        });
        List<SharePhoto> sharePhotos = new ArrayList<>();
        for (int i = 0; i < filePaths.size(); i++) {
            Uri fileUri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".provider", new File(filePaths.get(i)));
            sharePhotos.add(new SharePhoto.Builder().setImageUrl(fileUri).build());
        }
        SharePhotoContent content = new SharePhotoContent.Builder()
                .setShareHashtag(new ShareHashtag.Builder().setHashtag(text).build())
                .setPhotos(sharePhotos)
                .build();
        if (ShareDialog.canShow(SharePhotoContent.class)) {
            shareDialog.show(content);
        }
    }

    public String shareToFaceBookStory(String appId, String stickerImage, String backgroundImage, String backgroundTopColor, String backgroundBottomColor, String attributionURL, Context activity) {
        try {
            Map<String, Boolean> apps = getInstalledApps(activity);
            String packageName;
            if (apps.get("facebook")) {
                packageName = FACEBOOK_PACKAGE;
            } else if (apps.get("facebook-lite")) {
                packageName = FACEBOOK_LITE_PACKAGE;
            } else {
                return ERROR_APP_NOT_AVAILABLE;
            }

            Intent intent = new Intent(FACEBOOK_STORY_PACKAGE);


            intent.setType("image/*");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId);
            if (stickerImage != null) {
                File file = new File(stickerImage);
                Uri stickerImageFile = FileProvider.getUriForFile(activity, activity.getPackageName() + ".provider", file);
                intent.putExtra("interactive_asset_uri", stickerImageFile);
                activity.grantUriPermission(packageName, stickerImageFile, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            intent.putExtra("content_url", attributionURL);
            intent.putExtra("top_background_color", backgroundTopColor);
            intent.putExtra("bottom_background_color", backgroundBottomColor);
            if (backgroundImage != null) {
                File file1 = new File(backgroundImage);
                Uri backgroundImageUri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".provider", file1);
                intent.setDataAndType(backgroundImageUri, getMimeTypeOfFile(backgroundImage));
                activity.grantUriPermission(packageName, backgroundImageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            activity.startActivity(intent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }

    private String shareTextToPackage(
            String text,
            Context context,
            String packageName
    ) {
        try {
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setType("text/plain");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(Intent.EXTRA_TEXT, text);
            intent.putExtra("content_url", text);
            intent.putExtra("source_application", context.getPackageName());
            intent.putExtra(Intent.EXTRA_TITLE, text);
            intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", getFacebookAppId(context));
            intent.setPackage(packageName);
            context.startActivity(intent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }


    private String shareFilesToPackage(List<String> imagePaths, Context activity, String packageName) {
        if (imagePaths == null || imagePaths.isEmpty()) return "No files to share";
        Intent shareIntent = new Intent(Intent.ACTION_SEND_MULTIPLE);
        ArrayList<Uri> files = new ArrayList<Uri>();
        for (int i = 0; i < imagePaths.size(); i++) {
            Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(imagePaths.get(i)));
            files.add(fileUri);
        }
        shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, files);
        shareIntent.setType(getMimeTypeOfFile(imagePaths.get(0)));
        shareIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        shareIntent.setPackage(packageName);
//        if (packageName.equals(INSTAGRAM_PACKAGE) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            shareIntent.setComponent(ComponentName.createRelative(packageName, "com.instagram.share.handleractivity.ShareHandlerActivity")); //open instagram feed
//        }
        try {
            activity.startActivity(shareIntent);
            return SUCCESS;
        } catch (Exception e) {
            e.printStackTrace();
            return e.getLocalizedMessage();
        }
    }

    private String shareFileAndTextToPackage(String imagePath, String message, Context activity, String packageName) {
        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        if (imagePath != null) {
            Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(imagePath));
            shareIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
            shareIntent.setType(getMimeTypeOfFile(imagePath));
        } else {
            shareIntent.setType("text/plain");
        }
        shareIntent.putExtra(Intent.EXTRA_TEXT, message);
        shareIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        shareIntent.setPackage(packageName);
        if (packageName.equals(INSTAGRAM_PACKAGE) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            shareIntent.setComponent(ComponentName.createRelative(packageName, "com.instagram.share.handleractivity.ShareHandlerActivity")); //open instagram feed
        }
        try {
            activity.startActivity(shareIntent);
            return SUCCESS;
        } catch (Exception e) {
            e.printStackTrace();
            return e.getLocalizedMessage();
        }
    }

    public Map<String, Boolean> getInstalledApps(Context context) {
        Map<String, String> appsMap = new HashMap<>();
        String telegramApp = "telegram";
        appsMap.put("instagram", INSTAGRAM_PACKAGE);
        appsMap.put("facebook_stories", FACEBOOK_PACKAGE);
        appsMap.put("whatsapp", WHATSAPP_PACKAGE);
        appsMap.put("we_chat", WE_CHAT_PACKAGE);
        appsMap.put(telegramApp, TELEGRAM_PACKAGE);
        appsMap.put("messenger", FACEBOOK_MESSENGER_PACKAGE);
        appsMap.put("messenger-lite", FACEBOOK_MESSENGER_LITE_PACKAGE);
        appsMap.put("facebook", FACEBOOK_PACKAGE);
        appsMap.put("facebook-lite", FACEBOOK_LITE_PACKAGE);
        appsMap.put("instagram_stories", INSTAGRAM_PACKAGE);
        appsMap.put("twitter", TWITTER_PACKAGE);
        appsMap.put("tiktok", TIKTOK_PACKAGE);
    
        Map<String, Boolean> apps = new HashMap<>();
        PackageManager pm = context.getPackageManager();

        // Check for default messaging apps
        Intent intent = new Intent(Intent.ACTION_SENDTO).addCategory(Intent.CATEGORY_DEFAULT);
        intent.setType("vnd.android-dir/mms-sms");
        intent.setData(Uri.parse("sms:"));
        List<ResolveInfo> resolvedActivities = pm.queryIntentActivities(intent, 0);
        apps.put("message", !resolvedActivities.isEmpty());
    
        String[] appNames = {"instagram", "facebook_stories", "whatsapp", "we_chat" ,"telegram", "messenger", "facebook", "facebook-lite", "messenger-lite", "instagram_stories", "twitter", "tiktok"};
    
        for (String appName : appNames) {
            // Telegram has two types of package ids
            // Downloaded from Google play store & Website 
            if (appName.equals(telegramApp)) {
                // Check both packages
                boolean isTelegramInstalled = isPackageInstalled(TELEGRAM_PACKAGE, pm) 
                                              || isPackageInstalled(TELEGRAM_WEB_PACKAGE, pm);
                apps.put(telegramApp, isTelegramInstalled);
            } else {
                try {
                    isPackageInstalled(appsMap.get(appName), pm);
                    apps.put(appName, true);
                } catch (Exception e) {
                    apps.put(appName, false);
                }
            }
        }
        return apps;
    }
    
    /**
     * Helper method to check if a package is installed
     */
    private boolean isPackageInstalled(String packageName, PackageManager pm) {
        try {
            pm.getPackageInfo(packageName, pm.GET_META_DATA);
            return true;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }

    private static String getMimeTypeOfFile(String pathName) {
        try {
            Path path;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                path = new File(pathName).toPath();
                String mimeType = Files.probeContentType(path);
                return mimeType;
            }
            return "*/*";
        } catch (Exception e) {
            return "";
        }
    }


    String getFacebookAppId(Context activity) {
        String appId = "";
        try {
            ApplicationInfo appInfo = activity.getPackageManager().getApplicationInfo(
                    activity.getPackageName(), PackageManager.GET_META_DATA);

            Bundle metaData = appInfo.metaData;
            if (metaData != null) {
                appId = metaData.getString("com.facebook.sdk.ApplicationId");
                Log.d("FB_APP_ID", appId);
            }
        } catch (PackageManager.NameNotFoundException e) {
            // Handle the exception if needed
        }

        return appId;
    }

}