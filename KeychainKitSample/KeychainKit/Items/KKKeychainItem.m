//
//  KKKeychainItem.m
//  KeychainKitSample
//
//  Created by david on 17/12/14.
//  Copyright (c) 2014 David Live Org. All rights reserved.
//

#import "KKKeychainItem.h"
@import Security;
#import "KKKeychainItem+SuclassesInterface.h"
#import "KKKeychainOperation+KeychainKitInteface.h"
#import "NSMutableDictionary+KeychainKit.h"

@interface KKKeychainItem ()

/*!
 *  @abstract
 *      Item's content data.
 */
@property (nonatomic, copy, readwrite) NSData *data;
/*!
 *  @abstract
 *      User-visible label for this Keychain Item.
 *  @discussion
 *      Label is a property which can be seen as a key for the item from Keychain.
 *      This property is required when the item is updated.
 */
@property (nonatomic, copy, readwrite) NSString *label;
/*!
 *  @abstract
 *      Indicates which access group a Keychain Item is in.
 *
 *  @discussion
 *      Access groups can be used to share Keychain Items among two or more applications.
 *      For applications to share a keychain item, the applications must have a common 
 *      access group listed in their keychain-access-groups entitlement.
 */
@property (nonatomic, copy, readwrite) NSString *accessGroup;
/*!
 *  @abstract
 *      A value which indicates item's accessibility.
 *
 *  @discussion
 *      You should choose the most restrictive option that meets your app’s needs so
 *      that iOS can protect that item to the greatest extent possible.
 *      See enumeration for possible values.
 */
@property (nonatomic, assign, readwrite) KKKeychainItemAccessibility accessbility;

@end

@implementation KKKeychainItem

#pragma mark - Life Cycle

/*!
 *  Initiazes a Keychain Item using provided parameters.
 *
 *  @return An initialized object, or nil if an object could not be created for some
 *          reason that would not result in an exception.
 */
- (instancetype)initWithData:(NSData *)data label:(NSString *)label accessGroup:(NSString *)accessGroup
               accessibility:(KKKeychainItemAccessibility)accessibility {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.label = label;
        self.accessGroup = accessGroup;
        self.accessbility = accessibility;
    }
    
    return self;
}

#pragma mark - Keychain mapping

/*!
 *  @return CFTypeRef associated to access control protection chosen by item creator.
 */
- (CFTypeRef)accessControlProtectionFromItem {
    switch (self.accessbility) {
        case KKKeychainItemAccessibleAlways:
            return kSecAttrAccessibleAlways;
        case KKKeychainItemAccessibleAlwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly;
        case KKKeychainItemAccessibleAfterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock;
        case KKKeychainItemAccessibleAfterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
        case KKKeychainItemAccessibleWhenUnlocked:
            return kSecAttrAccessibleWhenUnlocked;
        case KKKeychainItemAccessibleWhenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
        case KKKeychainItemAccessibleWhenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
    }
}

#pragma mark - Item Conversion

/*!
 *  Converts Keychain Item into an NSDictionary.
 *
 *  @param error an error which will be set if something goes wrong.
 *
 *  @return An NSDictionary filled with data from Keychain Item. Will be empty if does not contain any data,
 */
- (NSDictionary *)keychainAttributesWithError:(NSError *__autoreleasing *)error {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    SecAccessControlRef (*pointerToSecAccessControlCreateWithFlags)(CFAllocatorRef allocator, CFTypeRef protection,
                                                                    SecAccessControlCreateFlags flags, CFErrorRef *error);
    pointerToSecAccessControlCreateWithFlags = SecAccessControlCreateWithFlags;
    if (pointerToSecAccessControlCreateWithFlags != nil) {
        CFErrorRef accessControlError = NULL;
        SecAccessControlRef accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                            [self accessControlProtectionFromItem],
                                                                            kSecAccessControlUserPresence,
                                                                            &accessControlError);
        if (accessControlError) { // was there any error
            *error = (__bridge_transfer NSError *)accessControlError;
            return nil;
        }
        [attributes setObjectSafely:(__bridge_transfer id)accessControl
                             forKey:(__bridge id)kSecAttrAccessControl];
    } else {
        [attributes setObject:(__bridge id)[self accessControlProtectionFromItem]
                       forKey:(__bridge id)kSecAttrAccessible];
    }
    [attributes setObjectSafely:self.data
                         forKey:(__bridge id)kSecValueData];
    return [attributes copy];
}


@end
