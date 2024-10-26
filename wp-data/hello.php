<?php
// Get the user's IP address
$user_ip = $_SERVER['REMOTE_ADDR'];

// Output the message
echo "Hello, user from IP: " . htmlspecialchars($user_ip);
?>
