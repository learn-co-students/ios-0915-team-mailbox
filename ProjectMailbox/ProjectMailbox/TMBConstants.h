//
//  TMBConstants.h
//  ProjectMailbox
//
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SPOTIFY_CLIENT_ID;
extern NSString *const SPOTIFY_REDIRECT_URL;
extern NSString *const SPOTIFY_TOKEN_SWAP_URL;
extern NSString *const SPOTIFY_TOKEN_REFRESH_URL;

@interface TMBConstants : NSObject


#pragma mark - NSUserDefaults
extern NSString *const kTMBUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kTMBUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kTMBLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const TMBAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const TMBUtilityUserFollowingChangedNotification;
extern NSString *const TMBUtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const TMBUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const TMBTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const TMBTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const TMBPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const TMBPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const TMBPhotoDetailsViewControllerUserCommentedOnPhotoNotification;


#pragma mark - User Info Keys
extern NSString *const TMBPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kTMBEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kTMBInstallationUserKey;
extern NSString *const kTMBInstallationChannelsKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kTMBActivityClassKey;

// Field keys
extern NSString *const kTMBActivityTypeKey;
extern NSString *const kTMBActivityFromUserKey;
extern NSString *const kTMBActivityToUserKey;
extern NSString *const kTMBActivityContentKey;
extern NSString *const kTMBActivityPhotoKey;

// Type values
extern NSString *const kTMBActivityTypeLike;
extern NSString *const kTMBActivityTypeFollow;
extern NSString *const kTMBActivityTypeComment;
extern NSString *const kTMBActivityTypeJoined;


#pragma mark - PFObject Board Class
// Class key
extern NSString *const kTMBBoardClassKey;

// Field keys
extern NSString *const kTMBBoardTypeKey;
extern NSString *const kTMBBoardFromUserKey;
extern NSString *const kTMBBoardToUserKey;
extern NSString *const kTMBBoardContentKey;

// Type values
extern NSString *const kTMBBoardTypeFollow;
extern NSString *const kTMBBoardTypeJoined;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kTMBUserDisplayNameKey;
extern NSString *const kTMBUserFacebookIDKey;
extern NSString *const kTMBUserPhotoIDKey;
extern NSString *const kTMBUserProfilePicSmallKey;
extern NSString *const kTMBUserProfilePicMediumKey;
extern NSString *const kTMBUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kTMBUserPrivateChannelKey;


#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kTMBPhotoClassKey;

// Field keys
extern NSString *const kTMBPhotoPictureKey;
extern NSString *const kTMBPhotoThumbnailKey;
extern NSString *const kTMBPhotoUserKey;


#pragma mark - Cached Photo Attributes
// keys
extern NSString *const kTMBPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kTMBPhotoAttributesLikeCountKey;
extern NSString *const kTMBPhotoAttributesLikersKey;
extern NSString *const kTMBPhotoAttributesCommentCountKey;
extern NSString *const kTMBPhotoAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kTMBUserAttributesPhotoCountKey;
extern NSString *const kTMBUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kTMBPushPayloadPayloadTypeKey;
extern NSString *const kTMBPushPayloadPayloadTypeActivityKey;

extern NSString *const kTMBPushPayloadActivityTypeKey;
extern NSString *const kTMBPushPayloadActivityLikeKey;
extern NSString *const kTMBPushPayloadActivityCommentKey;
extern NSString *const kTMBPushPayloadActivityFollowKey;

extern NSString *const kTMBPushPayloadFromUserObjectIdKey;
extern NSString *const kTMBPushPayloadToUserObjectIdKey;
extern NSString *const kTMBPushPayloadPhotoObjectIdKey;

@end
