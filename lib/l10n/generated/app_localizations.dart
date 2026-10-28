import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get homeUpNext;

  /// No description provided for @homeNothingDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing due. Nice work!'**
  String get homeNothingDue;

  /// No description provided for @taskFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get taskFilterAll;

  /// No description provided for @taskFilterAssignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Assigned to me'**
  String get taskFilterAssignedToMe;

  /// No description provided for @taskFilterMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get taskFilterMine;

  /// No description provided for @tasksNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No tasks match this filter.'**
  String get tasksNoMatch;

  /// No description provided for @tasksCurrentSection.
  ///
  /// In en, this message translates to:
  /// **'Current Tasks'**
  String get tasksCurrentSection;

  /// No description provided for @tasksCompletedSection.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get tasksCompletedSection;

  /// No description provided for @tasksNothingCurrent.
  ///
  /// In en, this message translates to:
  /// **'Nothing current.'**
  String get tasksNothingCurrent;

  /// No description provided for @tasksNothingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Nothing completed yet.'**
  String get tasksNothingCompleted;

  /// No description provided for @taskNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get taskNoDueDate;

  /// No description provided for @taskUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get taskUnassigned;

  /// No description provided for @taskYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get taskYou;

  /// No description provided for @taskDetailNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get taskDetailNewTitle;

  /// No description provided for @taskDetailMissing.
  ///
  /// In en, this message translates to:
  /// **'This task no longer exists.'**
  String get taskDetailMissing;

  /// No description provided for @taskDetailTaskNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskDetailTaskNameLabel;

  /// No description provided for @taskDetailDescriptionHeading.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDetailDescriptionHeading;

  /// No description provided for @taskDetailDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get taskDetailDescriptionHint;

  /// No description provided for @taskDetailNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get taskDetailNoDescription;

  /// No description provided for @taskDetailCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get taskDetailCreatedLabel;

  /// No description provided for @taskDetailDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get taskDetailDueLabel;

  /// No description provided for @taskDetailAssignerLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigner'**
  String get taskDetailAssignerLabel;

  /// No description provided for @taskDetailAssigneeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get taskDetailAssigneeLabel;

  /// No description provided for @taskDetailTapToSet.
  ///
  /// In en, this message translates to:
  /// **'Tap to set'**
  String get taskDetailTapToSet;

  /// No description provided for @taskDetailAddToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get taskDetailAddToCalendar;

  /// No description provided for @taskDetailStatusHeading.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskDetailStatusHeading;

  /// No description provided for @taskDetailCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get taskDetailCreateButton;

  /// No description provided for @taskDetailSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get taskDetailSaveButton;

  /// No description provided for @assignToTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign to'**
  String get assignToTitle;

  /// No description provided for @calendarAdded.
  ///
  /// In en, this message translates to:
  /// **'Opened in your calendar app.'**
  String get calendarAdded;

  /// No description provided for @calendarNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'Set a due date first.'**
  String get calendarNoDueDate;

  /// No description provided for @calendarUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Adding to calendar isn\'t supported on this platform yet.'**
  String get calendarUnsupported;

  /// No description provided for @calendarFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add this to your calendar.'**
  String get calendarFailed;

  /// No description provided for @titleRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Task name is required.'**
  String get titleRequiredError;

  /// No description provided for @dueDateTooSoonError.
  ///
  /// In en, this message translates to:
  /// **'Due time must be at least a minute after the creation time.'**
  String get dueDateTooSoonError;

  /// No description provided for @quickToggleBackToPending.
  ///
  /// In en, this message translates to:
  /// **'Back to pending'**
  String get quickToggleBackToPending;

  /// No description provided for @quickToggleMarkMyPartDone.
  ///
  /// In en, this message translates to:
  /// **'Mark my part done'**
  String get quickToggleMarkMyPartDone;

  /// No description provided for @quickToggleMarkAsPending.
  ///
  /// In en, this message translates to:
  /// **'Mark as pending'**
  String get quickToggleMarkAsPending;

  /// No description provided for @quickToggleMarkAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get quickToggleMarkAsComplete;

  /// No description provided for @taskStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get taskStatusAssigned;

  /// No description provided for @taskStatusWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get taskStatusWorking;

  /// No description provided for @taskStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskStatusPending;

  /// No description provided for @taskStatusOnReview.
  ///
  /// In en, this message translates to:
  /// **'On Review'**
  String get taskStatusOnReview;

  /// No description provided for @taskStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get taskStatusCompleted;

  /// No description provided for @taskStatusToBeRedone.
  ///
  /// In en, this message translates to:
  /// **'To be redone'**
  String get taskStatusToBeRedone;

  /// No description provided for @categoryEditorNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get categoryEditorNoCategories;

  /// No description provided for @categoryEditorAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoryEditorAddTitle;

  /// No description provided for @categoryEditorExisting.
  ///
  /// In en, this message translates to:
  /// **'Existing categories'**
  String get categoryEditorExisting;

  /// No description provided for @categoryEditorOrCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Or create a new one'**
  String get categoryEditorOrCreateNew;

  /// No description provided for @categoryEditorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryEditorNameHint;

  /// No description provided for @assigneePickerMyself.
  ///
  /// In en, this message translates to:
  /// **'Myself'**
  String get assigneePickerMyself;

  /// No description provided for @assigneePickerSearchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Not in your contacts? Search by username:'**
  String get assigneePickerSearchPrompt;

  /// No description provided for @assigneePickerLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to search for other accounts.'**
  String get assigneePickerLoginPrompt;

  /// No description provided for @searchUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get searchUsernameLabel;

  /// No description provided for @searchHintMinChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least {count} characters'**
  String searchHintMinChars(int count);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching user found.'**
  String get searchNoResults;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get profileNotLoggedIn;

  /// No description provided for @profileLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get profileLogIn;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogOut;

  /// No description provided for @profileContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get profileContacts;

  /// No description provided for @profileAddContactTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get profileAddContactTooltip;

  /// No description provided for @profileNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet.'**
  String get profileNoContacts;

  /// No description provided for @profileDeleteContactTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get profileDeleteContactTooltip;

  /// No description provided for @profileDeleteContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete contact?'**
  String get profileDeleteContactTitle;

  /// No description provided for @profileDeleteContactBody.
  ///
  /// In en, this message translates to:
  /// **'Do you really wish to delete \"{name}\" from contacts?'**
  String profileDeleteContactBody(String name);

  /// No description provided for @profileWhoCanFindYou.
  ///
  /// In en, this message translates to:
  /// **'Who can find you'**
  String get profileWhoCanFindYou;

  /// No description provided for @profilePrivacyUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update this — check your connection and try again.'**
  String get profilePrivacyUpdateError;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileLanguageSystemDefault;

  /// No description provided for @privacyAllowAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Allow all searches'**
  String get privacyAllowAllLabel;

  /// No description provided for @privacyAllowAllDescription.
  ///
  /// In en, this message translates to:
  /// **'Anyone can find you by typing part of your username.'**
  String get privacyAllowAllDescription;

  /// No description provided for @privacyExactUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Exact username only'**
  String get privacyExactUsernameLabel;

  /// No description provided for @privacyExactUsernameDescription.
  ///
  /// In en, this message translates to:
  /// **'Only findable if someone types your exact username.'**
  String get privacyExactUsernameDescription;

  /// No description provided for @privacyContactsPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Contacts/phone only'**
  String get privacyContactsPhoneLabel;

  /// No description provided for @privacyContactsPhoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Not findable by username at all — only by your exact phone number.'**
  String get privacyContactsPhoneDescription;

  /// No description provided for @countryUnitedStates.
  ///
  /// In en, this message translates to:
  /// **'United States (+1)'**
  String get countryUnitedStates;

  /// No description provided for @countryRussia.
  ///
  /// In en, this message translates to:
  /// **'Russia (+7)'**
  String get countryRussia;

  /// No description provided for @countryNetherlands.
  ///
  /// In en, this message translates to:
  /// **'Netherlands (+31)'**
  String get countryNetherlands;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountTitle;

  /// No description provided for @authLogInTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogInTitle;

  /// No description provided for @authUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name (optional)'**
  String get authFullNameLabel;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get authPhoneLabel;

  /// No description provided for @authCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get authCountryLabel;

  /// No description provided for @authUsernamePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Username and password are required.'**
  String get authUsernamePasswordRequired;

  /// No description provided for @authPickCountry.
  ///
  /// In en, this message translates to:
  /// **'Pick a country for the phone number.'**
  String get authPickCountry;

  /// No description provided for @authSwitchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get authSwitchToLogin;

  /// No description provided for @authSwitchToSignUp.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authSwitchToSignUp;

  /// No description provided for @addContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContactTitle;

  /// No description provided for @addContactNotOnApp.
  ///
  /// In en, this message translates to:
  /// **'Not on the app yet? Add them anyway'**
  String get addContactNotOnApp;

  /// No description provided for @addContactSearchInstead.
  ///
  /// In en, this message translates to:
  /// **'Search for a real account instead'**
  String get addContactSearchInstead;

  /// No description provided for @addContactDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get addContactDescriptionLabel;

  /// No description provided for @addContactUsernameEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Username and email are required.'**
  String get addContactUsernameEmailRequired;

  /// No description provided for @addContactFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add that contact.'**
  String get addContactFailed;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid email address.'**
  String get emailInvalid;

  /// No description provided for @phoneLengthError.
  ///
  /// In en, this message translates to:
  /// **'A {country} phone number should have {expected} digits (got {actual}).'**
  String phoneLengthError(String country, int expected, int actual);

  /// No description provided for @notificationDueIn.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is due in {hours, plural, =1{1 hour} other{{hours} hours}}'**
  String notificationDueIn(String title, num hours);

  /// No description provided for @notificationAssignedTitle.
  ///
  /// In en, this message translates to:
  /// **'New task assigned to you'**
  String get notificationAssignedTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
