<?php
$user = isset($_SERVER['REMOTE_USER']) ? $_SERVER['REMOTE_USER'] : '';
if ($user === 'admin@LAB.LAN' || $user === 'admin') {
    echo "<h1>WELCOME DOMAIN ADMINISTRATOR!</h1>";
    echo "<p>Special Authorization Token: <b>FLAG_ADMIN_SILVER_TICKET_OWNED</b></p>";
} else {
    echo "<h1>ACCESS DENIED</h1>";
    echo "<p>User '$user' is not authorized for Administrator Management Console.</p>";
}
?>
