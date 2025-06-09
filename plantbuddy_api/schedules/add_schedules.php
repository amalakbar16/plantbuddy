<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config/database.php';

// Aktifkan error log (opsional untuk debugging)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Koneksi database
$database = new Database();
$conn = $database->getConnection();
if (!$conn) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit();
}

// Ambil data dari body JSON
$input = json_decode(file_get_contents('php://input'), true);

// Validasi input yang wajib diisi
if (
    !isset($input['user_id']) ||
    !isset($input['plant_id']) ||
    !isset($input['repeat_type']) ||
    !isset($input['time']) ||
    !isset($input['reminder_enabled'])
) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Data jadwal tidak lengkap.']);
    exit();
}

$user_id = intval($input['user_id']);
$plant_id = intval($input['plant_id']);
$repeat_type = trim($input['repeat_type']);
$time = trim($input['time']); // Pastikan format "HH:MM"
$reminder_enabled = intval($input['reminder_enabled']);

try {
    $query = "INSERT INTO schedules (user_id, plant_id, repeat_type, time, reminder_enabled)
              VALUES (:user_id, :plant_id, :repeat_type, :time, :reminder_enabled)";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->bindParam(':plant_id', $plant_id, PDO::PARAM_INT);
    $stmt->bindParam(':repeat_type', $repeat_type);
    $stmt->bindParam(':time', $time);
    $stmt->bindParam(':reminder_enabled', $reminder_enabled, PDO::PARAM_INT);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Jadwal berhasil ditambahkan']);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Gagal menambahkan jadwal']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
