/**
 * Supabase Edge Function: check-reminders
 *
 * Berjalan setiap hari pukul 08:00 WIB (01:00 UTC) via pg_cron.
 *
 * Logic:
 * - Cari temuan: tgl_reminder IS NOT NULL, status Open, belum ada closing
 * - Yang mencapai H-1 hari ke-20 (yaitu: tgl_reminder + 19 hari = hari ini)
 * - Tulis record ke tabel [notifications] untuk: creator + semua admin
 * - Tidak mengirim push eksternal — notifikasi tampil saat user buka app
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

Deno.serve(async (_req) => {
  try {
    // Hitung tanggal trigger: tgl_reminder = 19 hari lalu → besok = hari ke-20
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const triggerDate = new Date(today);
    triggerDate.setDate(triggerDate.getDate() - 19);

    const triggerStr = triggerDate.toISOString().split("T")[0];
    const triggerNext = new Date(triggerDate.getTime() + 86_400_000)
      .toISOString()
      .split("T")[0];

    console.log(
      `[check-reminders] Mencari temuan dengan tgl_reminder: ${triggerStr}`
    );

    // 1. Ambil temuan yang memenuhi syarat
    const { data: temuanList, error: temuanErr } = await supabase
      .from("temuan")
      .select("id, nama_pemilik, lokasi, user_id, tgl_reminder, ulp")
      .is("jenis_closing", null)
      .eq("status_temuan", "Open")
      .gte("tgl_reminder", triggerStr)
      .lt("tgl_reminder", triggerNext);

    if (temuanErr) throw temuanErr;

    if (!temuanList || temuanList.length === 0) {
      console.log("[check-reminders] Tidak ada temuan yang memenuhi syarat");
      return new Response(
        JSON.stringify({ message: "Tidak ada temuan yang perlu dinotifikasi" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    console.log(`[check-reminders] Ditemukan ${temuanList.length} temuan`);

    // 2. Ambil semua user admin
    const { data: adminProfiles } = await supabase
      .from("profiles")
      .select("id")
      .eq("role", "admin");

    const adminIds: string[] = adminProfiles?.map((p: { id: string }) => p.id) ?? [];

    const notifRows: Array<{
      user_id: string;
      temuan_id: string;
      title: string;
      body: string;
      type: string;
    }> = [];

    for (const temuan of temuanList) {
      const tglReminder = new Date(temuan.tgl_reminder);
      const daysPassed = Math.floor((today.getTime() - tglReminder.getTime()) / 86_400_000);
      const title = `Temuan '${temuan.nama_pemilik}' belum ditindaklanjuti`;
      const body = `Sudah ${daysPassed} hari sejak pengingat diatur. Lokasi: ${temuan.lokasi}. ULP: ${temuan.ulp ?? '-'}. Segera lakukan tindak lanjut sebelum mencapai 20 hari.`;

      // Kumpulkan target: creator + admin (deduplicated)
      const targetIds = new Set<string>([temuan.user_id, ...adminIds]);

      for (const userId of targetIds) {
        // Hindari duplikat: satu temuan hanya boleh punya satu notif per user
        const { data: existing } = await supabase
          .from("notifications")
          .select("id")
          .eq("user_id", userId)
          .eq("temuan_id", temuan.id)
          .eq("type", "reminder_h1")
          .maybeSingle();

        if (!existing) {
          notifRows.push({
            user_id: userId,
            temuan_id: temuan.id,
            title,
            body,
            type: "reminder_h1",
          });
        }
      }
    }

    if (notifRows.length === 0) {
      console.log("[check-reminders] Semua notifikasi sudah terkirim hari ini");
      return new Response(
        JSON.stringify({ message: "Notifikasi sudah terkirim hari ini" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // 3. Insert semua notifikasi sekaligus
    const { error: insertErr } = await supabase
      .from("notifications")
      .insert(notifRows);

    if (insertErr) throw insertErr;

    const result = {
      message: `Berhasil: ${notifRows.length} notifikasi dibuat untuk ${temuanList.length} temuan`,
      temuan_count: temuanList.length,
      notifications_created: notifRows.length,
    };
    console.log("[check-reminders]", result.message);

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("[check-reminders] Error:", e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
