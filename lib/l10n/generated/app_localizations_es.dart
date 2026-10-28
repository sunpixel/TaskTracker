// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get add => 'Añadir';

  @override
  String get close => 'Cerrar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navTasks => 'Tareas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get homeUpNext => 'Próximamente';

  @override
  String get homeNothingDue => 'Nada pendiente. ¡Buen trabajo!';

  @override
  String get taskFilterAll => 'Todas';

  @override
  String get taskFilterAssignedToMe => 'Asignadas a mí';

  @override
  String get taskFilterMine => 'Mías';

  @override
  String get tasksNoMatch => 'Ninguna tarea coincide con este filtro.';

  @override
  String get tasksCurrentSection => 'Tareas actuales';

  @override
  String get tasksCompletedSection => 'Tareas completadas';

  @override
  String get tasksNothingCurrent => 'No hay tareas actuales.';

  @override
  String get tasksNothingCompleted => 'Aún no hay nada completado.';

  @override
  String get taskNoDueDate => 'Sin fecha límite';

  @override
  String get taskUnassigned => 'Sin asignar';

  @override
  String get taskYou => 'Tú';

  @override
  String get taskDetailNewTitle => 'Nueva tarea';

  @override
  String get taskDetailMissing => 'Esta tarea ya no existe.';

  @override
  String get taskDetailTaskNameLabel => 'Nombre de la tarea';

  @override
  String get taskDetailDescriptionHeading => 'Descripción';

  @override
  String get taskDetailDescriptionHint => '¿Qué hay que hacer?';

  @override
  String get taskDetailNoDescription => 'Sin descripción.';

  @override
  String get taskDetailCreatedLabel => 'Creada';

  @override
  String get taskDetailDueLabel => 'Vence';

  @override
  String get taskDetailAssignerLabel => 'Asignada por';

  @override
  String get taskDetailAssigneeLabel => 'Asignada a';

  @override
  String get taskDetailTapToSet => 'Toca para establecer';

  @override
  String get taskDetailAddToCalendar => 'Añadir al calendario';

  @override
  String get taskDetailStatusHeading => 'Estado';

  @override
  String get taskDetailCreateButton => 'Crear tarea';

  @override
  String get taskDetailSaveButton => 'Guardar cambios';

  @override
  String get assignToTitle => 'Asignar a';

  @override
  String get calendarAdded => 'Abierto en tu app de calendario.';

  @override
  String get calendarNoDueDate => 'Establece primero una fecha límite.';

  @override
  String get calendarUnsupported =>
      'Añadir al calendario aún no es compatible con esta plataforma.';

  @override
  String get calendarFailed => 'No se pudo añadir esto al calendario.';

  @override
  String get titleRequiredError => 'El nombre de la tarea es obligatorio.';

  @override
  String get dueDateTooSoonError =>
      'La fecha límite debe ser al menos un minuto posterior a la de creación.';

  @override
  String get quickToggleBackToPending => 'Volver a pendiente';

  @override
  String get quickToggleMarkMyPartDone => 'Marcar mi parte como hecha';

  @override
  String get quickToggleMarkAsPending => 'Marcar como pendiente';

  @override
  String get quickToggleMarkAsComplete => 'Marcar como completada';

  @override
  String get taskStatusAssigned => 'Asignada';

  @override
  String get taskStatusWorking => 'En curso';

  @override
  String get taskStatusPending => 'Pendiente';

  @override
  String get taskStatusOnReview => 'En revisión';

  @override
  String get taskStatusCompleted => 'Completada';

  @override
  String get taskStatusToBeRedone => 'Para rehacer';

  @override
  String get categoryEditorNoCategories => 'Sin categorías';

  @override
  String get categoryEditorAddTitle => 'Añadir categoría';

  @override
  String get categoryEditorExisting => 'Categorías existentes';

  @override
  String get categoryEditorOrCreateNew => 'O crea una nueva';

  @override
  String get categoryEditorNameHint => 'Nombre de la categoría';

  @override
  String get assigneePickerMyself => 'A mí mismo';

  @override
  String get assigneePickerSearchPrompt =>
      '¿No está en tus contactos? Busca por nombre de usuario:';

  @override
  String get assigneePickerLoginPrompt =>
      'Inicia sesión para buscar otras cuentas.';

  @override
  String get searchUsernameLabel => 'Nombre de usuario';

  @override
  String searchHintMinChars(int count) {
    return 'Escribe al menos $count caracteres';
  }

  @override
  String get searchNoResults => 'No se encontró ningún usuario.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileNotLoggedIn => 'No has iniciado sesión';

  @override
  String get profileLogIn => 'Iniciar sesión';

  @override
  String get profileLogOut => 'Cerrar sesión';

  @override
  String get profileContacts => 'Contactos';

  @override
  String get profileAddContactTooltip => 'Añadir contacto';

  @override
  String get profileNoContacts => 'Aún no hay contactos.';

  @override
  String get profileDeleteContactTooltip => 'Eliminar contacto';

  @override
  String get profileDeleteContactTitle => '¿Eliminar contacto?';

  @override
  String profileDeleteContactBody(String name) {
    return '¿Seguro que quieres eliminar a «$name» de tus contactos?';
  }

  @override
  String get profileWhoCanFindYou => 'Quién puede encontrarte';

  @override
  String get profilePrivacyUpdateError =>
      'No se pudo actualizar esto — comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get profileAppearance => 'Apariencia';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileLanguageSystemDefault => 'Predeterminado del sistema';

  @override
  String get privacyAllowAllLabel => 'Permitir cualquier búsqueda';

  @override
  String get privacyAllowAllDescription =>
      'Cualquiera puede encontrarte escribiendo parte de tu nombre de usuario.';

  @override
  String get privacyExactUsernameLabel => 'Solo nombre de usuario exacto';

  @override
  String get privacyExactUsernameDescription =>
      'Solo se te puede encontrar si alguien escribe tu nombre de usuario exacto.';

  @override
  String get privacyContactsPhoneLabel => 'Solo contactos/teléfono';

  @override
  String get privacyContactsPhoneDescription =>
      'No se te puede encontrar por nombre de usuario — solo por tu número de teléfono exacto.';

  @override
  String get countryUnitedStates => 'Estados Unidos (+1)';

  @override
  String get countryRussia => 'Rusia (+7)';

  @override
  String get countryNetherlands => 'Países Bajos (+31)';

  @override
  String get authCreateAccountTitle => 'Crear cuenta';

  @override
  String get authLogInTitle => 'Iniciar sesión';

  @override
  String get authUsernameLabel => 'Nombre de usuario';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authFullNameLabel => 'Nombre completo (opcional)';

  @override
  String get authPhoneLabel => 'Teléfono (opcional)';

  @override
  String get authCountryLabel => 'País';

  @override
  String get authUsernamePasswordRequired =>
      'El nombre de usuario y la contraseña son obligatorios.';

  @override
  String get authPickCountry => 'Elige un país para el número de teléfono.';

  @override
  String get authSwitchToLogin => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get authSwitchToSignUp => '¿Nuevo aquí? Crea una cuenta';

  @override
  String get addContactTitle => 'Añadir contacto';

  @override
  String get addContactNotOnApp =>
      '¿Aún no está en la app? Añádelo de todos modos';

  @override
  String get addContactSearchInstead => 'Buscar una cuenta real en su lugar';

  @override
  String get addContactDescriptionLabel => 'Descripción (opcional)';

  @override
  String get addContactUsernameEmailRequired =>
      'El nombre de usuario y el correo son obligatorios.';

  @override
  String get addContactFailed => 'No se pudo añadir ese contacto.';

  @override
  String get emailRequired => 'El correo electrónico es obligatorio.';

  @override
  String get emailInvalid => 'Eso no parece una dirección de correo válida.';

  @override
  String phoneLengthError(String country, int expected, int actual) {
    return 'Un número de teléfono de $country debe tener $expected dígitos (se introdujeron $actual).';
  }

  @override
  String notificationDueIn(String title, num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return '\"$title\" vence en $_temp0';
  }

  @override
  String get notificationAssignedTitle => 'Se te ha asignado una nueva tarea';
}
