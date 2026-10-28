// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeUpNext => 'Up next';

  @override
  String get homeNothingDue => 'Nothing due. Nice work!';

  @override
  String get taskFilterAll => 'All';

  @override
  String get taskFilterAssignedToMe => 'Assigned to me';

  @override
  String get taskFilterMine => 'Mine';

  @override
  String get tasksNoMatch => 'No tasks match this filter.';

  @override
  String get tasksCurrentSection => 'Current Tasks';

  @override
  String get tasksCompletedSection => 'Completed Tasks';

  @override
  String get tasksNothingCurrent => 'Nothing current.';

  @override
  String get tasksNothingCompleted => 'Nothing completed yet.';

  @override
  String get taskNoDueDate => 'No due date';

  @override
  String get taskUnassigned => 'Unassigned';

  @override
  String get taskYou => 'You';

  @override
  String get taskDetailNewTitle => 'New task';

  @override
  String get taskDetailMissing => 'This task no longer exists.';

  @override
  String get taskDetailTaskNameLabel => 'Task name';

  @override
  String get taskDetailDescriptionHeading => 'Description';

  @override
  String get taskDetailDescriptionHint => 'What needs to be done?';

  @override
  String get taskDetailNoDescription => 'No description.';

  @override
  String get taskDetailCreatedLabel => 'Created';

  @override
  String get taskDetailDueLabel => 'Due';

  @override
  String get taskDetailAssignerLabel => 'Assigner';

  @override
  String get taskDetailAssigneeLabel => 'Assignee';

  @override
  String get taskDetailTapToSet => 'Tap to set';

  @override
  String get taskDetailAddToCalendar => 'Add to calendar';

  @override
  String get taskDetailStatusHeading => 'Status';

  @override
  String get taskDetailCreateButton => 'Create task';

  @override
  String get taskDetailSaveButton => 'Save changes';

  @override
  String get assignToTitle => 'Assign to';

  @override
  String get calendarAdded => 'Opened in your calendar app.';

  @override
  String get calendarNoDueDate => 'Set a due date first.';

  @override
  String get calendarUnsupported =>
      'Adding to calendar isn\'t supported on this platform yet.';

  @override
  String get calendarFailed => 'Could not add this to your calendar.';

  @override
  String get titleRequiredError => 'Task name is required.';

  @override
  String get dueDateTooSoonError =>
      'Due time must be at least a minute after the creation time.';

  @override
  String get quickToggleBackToPending => 'Back to pending';

  @override
  String get quickToggleMarkMyPartDone => 'Mark my part done';

  @override
  String get quickToggleMarkAsPending => 'Mark as pending';

  @override
  String get quickToggleMarkAsComplete => 'Mark as complete';

  @override
  String get taskStatusAssigned => 'Assigned';

  @override
  String get taskStatusWorking => 'Working';

  @override
  String get taskStatusPending => 'Pending';

  @override
  String get taskStatusOnReview => 'On Review';

  @override
  String get taskStatusCompleted => 'Complete';

  @override
  String get taskStatusToBeRedone => 'To be redone';

  @override
  String get categoryEditorNoCategories => 'No categories';

  @override
  String get categoryEditorAddTitle => 'Add category';

  @override
  String get categoryEditorExisting => 'Existing categories';

  @override
  String get categoryEditorOrCreateNew => 'Or create a new one';

  @override
  String get categoryEditorNameHint => 'Category name';

  @override
  String get assigneePickerMyself => 'Myself';

  @override
  String get assigneePickerSearchPrompt =>
      'Not in your contacts? Search by username:';

  @override
  String get assigneePickerLoginPrompt =>
      'Log in to search for other accounts.';

  @override
  String get searchUsernameLabel => 'Username';

  @override
  String searchHintMinChars(int count) {
    return 'Type at least $count characters';
  }

  @override
  String get searchNoResults => 'No matching user found.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNotLoggedIn => 'Not logged in';

  @override
  String get profileLogIn => 'Log in';

  @override
  String get profileLogOut => 'Log out';

  @override
  String get profileContacts => 'Contacts';

  @override
  String get profileAddContactTooltip => 'Add contact';

  @override
  String get profileNoContacts => 'No contacts yet.';

  @override
  String get profileDeleteContactTooltip => 'Delete contact';

  @override
  String get profileDeleteContactTitle => 'Delete contact?';

  @override
  String profileDeleteContactBody(String name) {
    return 'Do you really wish to delete \"$name\" from contacts?';
  }

  @override
  String get profileWhoCanFindYou => 'Who can find you';

  @override
  String get profilePrivacyUpdateError =>
      'Couldn\'t update this — check your connection and try again.';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageSystemDefault => 'System default';

  @override
  String get privacyAllowAllLabel => 'Allow all searches';

  @override
  String get privacyAllowAllDescription =>
      'Anyone can find you by typing part of your username.';

  @override
  String get privacyExactUsernameLabel => 'Exact username only';

  @override
  String get privacyExactUsernameDescription =>
      'Only findable if someone types your exact username.';

  @override
  String get privacyContactsPhoneLabel => 'Contacts/phone only';

  @override
  String get privacyContactsPhoneDescription =>
      'Not findable by username at all — only by your exact phone number.';

  @override
  String get countryUnitedStates => 'United States (+1)';

  @override
  String get countryRussia => 'Russia (+7)';

  @override
  String get countryNetherlands => 'Netherlands (+31)';

  @override
  String get authCreateAccountTitle => 'Create account';

  @override
  String get authLogInTitle => 'Log in';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authFullNameLabel => 'Full name (optional)';

  @override
  String get authPhoneLabel => 'Phone (optional)';

  @override
  String get authCountryLabel => 'Country';

  @override
  String get authUsernamePasswordRequired =>
      'Username and password are required.';

  @override
  String get authPickCountry => 'Pick a country for the phone number.';

  @override
  String get authSwitchToLogin => 'Already have an account? Log in';

  @override
  String get authSwitchToSignUp => 'New here? Create an account';

  @override
  String get addContactTitle => 'Add contact';

  @override
  String get addContactNotOnApp => 'Not on the app yet? Add them anyway';

  @override
  String get addContactSearchInstead => 'Search for a real account instead';

  @override
  String get addContactDescriptionLabel => 'Description (optional)';

  @override
  String get addContactUsernameEmailRequired =>
      'Username and email are required.';

  @override
  String get addContactFailed => 'Could not add that contact.';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get emailInvalid => 'That doesn\'t look like a valid email address.';

  @override
  String phoneLengthError(String country, int expected, int actual) {
    return 'A $country phone number should have $expected digits (got $actual).';
  }

  @override
  String notificationDueIn(String title, num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return '\"$title\" is due in $_temp0';
  }

  @override
  String get notificationAssignedTitle => 'New task assigned to you';
}
