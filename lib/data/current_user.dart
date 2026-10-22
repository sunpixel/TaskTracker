/// Placeholder identity for the logged-in user.
///
/// There's no auth/backend yet, so this stands in for "me" wherever a
/// task's [assignee]/[assigner] needs to be compared against the current
/// user (e.g. to decide whether a task is "Assigned to me" or "Mine").
/// Replace with the real user id once accounts/login exist.
const String currentUserId = 'me';
