// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get add => 'Добавить';

  @override
  String get close => 'Закрыть';

  @override
  String get navHome => 'Главная';

  @override
  String get navTasks => 'Задачи';

  @override
  String get navProfile => 'Профиль';

  @override
  String get homeUpNext => 'Скоро';

  @override
  String get homeNothingDue => 'Нет срочных задач. Отличная работа!';

  @override
  String get taskFilterAll => 'Все';

  @override
  String get taskFilterAssignedToMe => 'Назначено мне';

  @override
  String get taskFilterMine => 'Мои';

  @override
  String get tasksNoMatch => 'Нет задач, соответствующих фильтру.';

  @override
  String get tasksCurrentSection => 'Текущие задачи';

  @override
  String get tasksCompletedSection => 'Завершённые задачи';

  @override
  String get tasksNothingCurrent => 'Текущих задач нет.';

  @override
  String get tasksNothingCompleted => 'Пока ничего не завершено.';

  @override
  String get taskNoDueDate => 'Нет срока';

  @override
  String get taskUnassigned => 'Не назначено';

  @override
  String get taskYou => 'Вы';

  @override
  String get taskDetailNewTitle => 'Новая задача';

  @override
  String get taskDetailMissing => 'Эта задача больше не существует.';

  @override
  String get taskDetailTaskNameLabel => 'Название задачи';

  @override
  String get taskDetailDescriptionHeading => 'Описание';

  @override
  String get taskDetailDescriptionHint => 'Что нужно сделать?';

  @override
  String get taskDetailNoDescription => 'Нет описания.';

  @override
  String get taskDetailCreatedLabel => 'Создано';

  @override
  String get taskDetailDueLabel => 'Срок';

  @override
  String get taskDetailAssignerLabel => 'Поручил';

  @override
  String get taskDetailAssigneeLabel => 'Исполнитель';

  @override
  String get taskDetailTapToSet => 'Нажмите, чтобы указать';

  @override
  String get taskDetailAddToCalendar => 'Добавить в календарь';

  @override
  String get taskDetailStatusHeading => 'Статус';

  @override
  String get taskDetailCreateButton => 'Создать задачу';

  @override
  String get taskDetailSaveButton => 'Сохранить изменения';

  @override
  String get assignToTitle => 'Назначить';

  @override
  String get calendarAdded => 'Открыто в приложении календаря.';

  @override
  String get calendarNoDueDate => 'Сначала укажите срок выполнения.';

  @override
  String get calendarUnsupported =>
      'Добавление в календарь пока не поддерживается на этой платформе.';

  @override
  String get calendarFailed => 'Не удалось добавить это в календарь.';

  @override
  String get titleRequiredError => 'Название задачи обязательно.';

  @override
  String get dueDateTooSoonError =>
      'Срок выполнения должен быть минимум на минуту позже времени создания.';

  @override
  String get quickToggleBackToPending => 'Вернуть в ожидание';

  @override
  String get quickToggleMarkMyPartDone => 'Отметить свою часть выполненной';

  @override
  String get quickToggleMarkAsPending => 'Отметить как в ожидании';

  @override
  String get quickToggleMarkAsComplete => 'Отметить как выполненное';

  @override
  String get taskStatusAssigned => 'Назначено';

  @override
  String get taskStatusWorking => 'В работе';

  @override
  String get taskStatusPending => 'В ожидании';

  @override
  String get taskStatusOnReview => 'На проверке';

  @override
  String get taskStatusCompleted => 'Выполнено';

  @override
  String get taskStatusToBeRedone => 'На переделку';

  @override
  String get categoryEditorNoCategories => 'Нет категорий';

  @override
  String get categoryEditorAddTitle => 'Добавить категорию';

  @override
  String get categoryEditorExisting => 'Существующие категории';

  @override
  String get categoryEditorOrCreateNew => 'Или создайте новую';

  @override
  String get categoryEditorNameHint => 'Название категории';

  @override
  String get assigneePickerMyself => 'Себе';

  @override
  String get assigneePickerSearchPrompt =>
      'Не в контактах? Найдите по имени пользователя:';

  @override
  String get assigneePickerLoginPrompt =>
      'Войдите, чтобы искать другие аккаунты.';

  @override
  String get searchUsernameLabel => 'Имя пользователя';

  @override
  String searchHintMinChars(int count) {
    return 'Введите не менее $count символов';
  }

  @override
  String get searchNoResults => 'Пользователь не найден.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileNotLoggedIn => 'Вы не вошли в систему';

  @override
  String get profileLogIn => 'Войти';

  @override
  String get profileLogOut => 'Выйти';

  @override
  String get profileContacts => 'Контакты';

  @override
  String get profileAddContactTooltip => 'Добавить контакт';

  @override
  String get profileNoContacts => 'Пока нет контактов.';

  @override
  String get profileDeleteContactTooltip => 'Удалить контакт';

  @override
  String get profileDeleteContactTitle => 'Удалить контакт?';

  @override
  String profileDeleteContactBody(String name) {
    return 'Вы действительно хотите удалить «$name» из контактов?';
  }

  @override
  String get profileWhoCanFindYou => 'Кто может вас найти';

  @override
  String get profilePrivacyUpdateError =>
      'Не удалось обновить настройку — проверьте соединение и попробуйте снова.';

  @override
  String get profileAppearance => 'Внешний вид';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileLanguageSystemDefault => 'Как в системе';

  @override
  String get privacyAllowAllLabel => 'Разрешить любой поиск';

  @override
  String get privacyAllowAllDescription =>
      'Любой может найти вас, введя часть имени пользователя.';

  @override
  String get privacyExactUsernameLabel => 'Только по точному имени';

  @override
  String get privacyExactUsernameDescription =>
      'Вас можно найти, только если ввести ваше имя пользователя полностью.';

  @override
  String get privacyContactsPhoneLabel => 'Только контакты/телефон';

  @override
  String get privacyContactsPhoneDescription =>
      'Вас нельзя найти по имени пользователя — только по точному номеру телефона.';

  @override
  String get countryUnitedStates => 'США (+1)';

  @override
  String get countryRussia => 'Россия (+7)';

  @override
  String get countryNetherlands => 'Нидерланды (+31)';

  @override
  String get authCreateAccountTitle => 'Создать аккаунт';

  @override
  String get authLogInTitle => 'Вход';

  @override
  String get authUsernameLabel => 'Имя пользователя';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authFullNameLabel => 'Полное имя (необязательно)';

  @override
  String get authPhoneLabel => 'Телефон (необязательно)';

  @override
  String get authCountryLabel => 'Страна';

  @override
  String get authUsernamePasswordRequired =>
      'Введите имя пользователя и пароль.';

  @override
  String get authPickCountry => 'Укажите страну для номера телефона.';

  @override
  String get authSwitchToLogin => 'Уже есть аккаунт? Войти';

  @override
  String get authSwitchToSignUp => 'Впервые здесь? Создать аккаунт';

  @override
  String get addContactTitle => 'Добавить контакт';

  @override
  String get addContactNotOnApp => 'Ещё не в приложении? Добавить всё равно';

  @override
  String get addContactSearchInstead => 'Искать существующий аккаунт';

  @override
  String get addContactDescriptionLabel => 'Описание (необязательно)';

  @override
  String get addContactUsernameEmailRequired =>
      'Введите имя пользователя и email.';

  @override
  String get addContactFailed => 'Не удалось добавить этот контакт.';

  @override
  String get emailRequired => 'Укажите email.';

  @override
  String get emailInvalid => 'Это не похоже на настоящий email-адрес.';

  @override
  String phoneLengthError(String country, int expected, int actual) {
    return 'Номер телефона для страны «$country» должен содержать $expected цифр (введено $actual).';
  }

  @override
  String notificationDueIn(String title, num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours часа',
      many: '$hours часов',
      few: '$hours часа',
      one: '1 час',
    );
    return '«$title» нужно выполнить через $_temp0';
  }

  @override
  String get notificationAssignedTitle => 'Вам назначена новая задача';
}
