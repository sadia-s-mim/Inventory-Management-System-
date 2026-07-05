<?php
session_start();
require_once '../config/database.php';
require_once '../config/constants.php';
require_once '../includes/functions.php';
require_once '../includes/auth_check.php';
requireRole([ROLE_ADMIN]);

$id = (int)($_GET['id'] ?? 0);
$stmt = $conn->prepare("SELECT supplier_name FROM suppliers WHERE supplier_id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();
$supplier = $stmt->get_result()->fetch_assoc();

if ($supplier) {
    $del = $conn->prepare("DELETE FROM suppliers WHERE supplier_id = ?");
    $del->bind_param("i", $id);
    if ($del->execute()) {
        logActivity($conn, $_SESSION['user_id'], 'Delete Supplier', "Deleted supplier: " . $supplier['supplier_name']);
        flash('success', 'Supplier deleted.');
    } else {
        flash('danger', 'Could not delete — this supplier has linked products or stock-in records.');
    }
} else {
    flash('danger', 'Supplier not found.');
}
redirect('suppliers/list.php');
