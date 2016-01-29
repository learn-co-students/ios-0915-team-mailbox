//
//  TMBConstants.m
//  ProjectMailbox
//
#import <Foundation/Foundation.h>
#import "TMBConstants.h"

NSString *const SPOTIFY_CLIENT_ID = @"27a059ea69fe472e9db0dfe484555f31";
NSString *const SPOTIFY_REDIRECT_URL = @"rar-spotify-test://callback";
NSString *const SPOTIFY_TOKEN_SWAP_URL = @"https://ios-0915-mailbox.herokuapp.com/swap";
NSString *const SPOTIFY_TOKEN_REFRESH_URL = @"https://ios-0915-mailbox.herokuapp.com/refresh";

@interface TMBConstants ()
@end

@implementation TMBConstants

NSString *const kTMBUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Anypic.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kTMBUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Anypic.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs

NSString *const kTMBLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const TMBAppDelegateApplicationDidReceiveRemoteNotification           = @"com.parse.Anypic.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const TMBUtilityUserFollowingChangedNotification                      = @"com.parse.Anypic.utility.userFollowingChanged";
NSString *const TMBUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.parse.Anypic.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const TMBUtilityDidFinishProcessingProfilePictureNotification         = @"com.parse.Anypic.utility.didFinishProcessingProfilePictureNotification";
NSString *const TMBTabBarControllerDidFinishEditingPhotoNotification            = @"com.parse.Anypic.tabBarController.didFinishEditingPhoto";
NSString *const TMBTabBarControllerDidFinishImageFileUploadNotification         = @"com.parse.Anypic.tabBarController.didFinishImageFileUploadNotification";
NSString *const TMBPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.parse.Anypic.photoDetailsViewController.userDeletedPhoto";
NSString *const TMBPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.parse.Anypic.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const TMBPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.parse.Anypic.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const TMBPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kTMBEditPhotoViewControllerUserInfoCommentKey = @"comment";
//
//#pragma mark - Installation Class
//
//// Field keys
NSString *const kTMBInstallationUserKey = @"user";
NSString *const kTMBInstallationChannelsKey = @"channels";
//
#pragma mark - Activity Class
// Class key
NSString *const kTMBActivityClassKey = @"Activity";

// Field keys
NSString *const kTMBActivityTypeKey        = @"type";
NSString *const kTMBActivityFromUserKey    = @"fromUser";
NSString *const kTMBActivityToUserKey      = @"toUser";
NSString *const kTMBActivityContentKey     = @"content";
NSString *const kTMBActivityPhotoKey       = @"photo";

// Type values
NSString *const kTMBActivityTypeLike       = @"like";
NSString *const kTMBActivityTypeFollow     = @"follow";
NSString *const kTMBActivityTypeComment    = @"comment";
NSString *const kTMBActivityTypeJoined     = @"joined";


#pragma mark - Board Class
// Class key
NSString *const kTMBBoardClassKey = @"Board";

// Field keys
NSString *const kTMBBoardTypeKey            = @"type";
NSString *const kTMBBoardFromUserKey        = @"fromUser";
NSString *const kTMBBoardToUserKey          = @"toUser";
NSString *const kTMBBoardContentKey         = @"content";
NSString *const kTMBBoardUsersKey           = @"users";

// Type values
NSString *const kTMBBoardTypeFollow     = @"follow";
NSString *const kTMBBoardTypeJoined     = @"joined";


#pragma mark - User Class
// Field keys
NSString *const kTMBUserObjectIdKey        = @"objectId";
NSString *const kTMBUserUsernameKey        = @"username";
NSString *const kTMBUserFirstNameKey       = @"First_Name";
NSString *const kTMBUserLastNameKey        = @"Last_Name";
NSString *const kTMBUserEmailKey           = @"email";
NSString *const kTMBUserProfileImageKey    = @"profileImage";

NSString *const kTMBUserDisplayNameKey                          = @"displayName";
NSString *const kTMBUserFacebookIDKey                           = @"facebookId";
NSString *const kTMBUserPhotoIDKey                              = @"photoId";
NSString *const kTMBUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kTMBUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kTMBUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kTMBUserPrivateChannelKey                       = @"channel";

#pragma mark - Photo Class
// Class key
NSString *const kTMBPhotoClassKey = @"Photo";

// Field keys
NSString *const kTMBPhotoPictureKey         = @"image";
NSString *const kTMBPhotoThumbnailKey       = @"thumbnail";
NSString *const kTMBPhotoUserKey            = @"user";


#pragma mark - Cached Photo Attributes
// keys
NSString *const kTMBPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kTMBPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kTMBPhotoAttributesLikersKey               = @"likers";
NSString *const kTMBPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kTMBPhotoAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kTMBUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kTMBUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kTMBPushPayloadPayloadTypeKey          = @"p";
NSString *const kTMBPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kTMBPushPayloadActivityTypeKey     = @"t";
NSString *const kTMBPushPayloadActivityLikeKey     = @"l";
NSString *const kTMBPushPayloadActivityCommentKey  = @"c";
NSString *const kTMBPushPayloadActivityFollowKey   = @"f";

NSString *const kTMBPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kTMBPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kTMBPushPayloadPhotoObjectIdKey    = @"pid";
@end
