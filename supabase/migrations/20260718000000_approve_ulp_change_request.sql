create or replace function public.approve_ulp_change_request(p_request_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  request_row public.ulp_change_requests%rowtype;
begin
  if not exists (
    select 1
    from public.profiles
    where id = auth.uid() and role = 'admin'
  ) then
    raise exception 'Hanya admin yang dapat menyetujui perubahan ULP';
  end if;

  select *
  into request_row
  from public.ulp_change_requests
  where id = p_request_id and status = 'pending'
  for update;

  if not found then
    raise exception 'Permintaan tidak ditemukan atau sudah diproses';
  end if;

  update public.profiles
  set ulp = request_row.ulp_baru,
      ulp_status = 'active'
  where id = request_row.user_id;

  if not found then
    raise exception 'Profil pengguna pemohon tidak ditemukan';
  end if;

  update public.ulp_change_requests
  set status = 'approved',
      reviewed_by = auth.uid(),
      reviewed_at = timezone('utc', now())
  where id = p_request_id;

  insert into public.notifications (user_id, title, body, type, is_read)
  values (
    request_row.user_id,
    'Perubahan ULP disetujui',
    format('ULP Anda telah diubah menjadi %s.', request_row.ulp_baru),
    'ulp_change_approved',
    false
  );
end;
$$;

revoke all on function public.approve_ulp_change_request(uuid) from public;
grant execute on function public.approve_ulp_change_request(uuid) to authenticated;
