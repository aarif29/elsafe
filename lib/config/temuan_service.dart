// config/temuan_service.dart - Tambahkan method ini
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'temuan_model.dart';

class TemuanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getAllTemuanSilent() async {
    try {
      print('🔄 Memulai getAllTemuanSilent...');
      
      final response = await _supabase
          .from('temuan')
          .select()
          .order('created_at', ascending: false);
      
      print('📦 Raw response: $response');
      
      if (response == null) {
        throw Exception('Response null dari Supabase');
      }

      List<TemuanModel> temuanList = [];
      
      if (response is List) {
        for (var item in response) {
          try {
            temuanList.add(TemuanModel.fromJson(item));
          } catch (e) {
            print('❌ Error parsing item: $item, Error: $e');
          }
        }
      }

      print('✅ Berhasil parse ${temuanList.length} items');
      
      return {
        'success': true,
        'data': temuanList,
        'message': 'Data berhasil diambil'
      };
    } catch (e) {
      print('❌ Error di getAllTemuanSilent: $e');
      
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Gagal mengambil data: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> deleteTemuanSilent(String id) async {
    try {
      print('🔄 Memulai deleteTemuanSilent untuk ID: $id');
      
      await _supabase
          .from('temuan')
          .delete()
          .eq('id', id);

      print('✅ Data berhasil dihapus');
      
      return {
        'success': true,
        'message': 'Data berhasil dihapus!'
      };
    } catch (e) {
      print('❌ Error di deleteTemuanSilent: $e');
      
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Gagal menghapus data: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> createTemuanSilent(TemuanModel temuan) async {
    try {
      print('🔄 Memulai createTemuanSilent...');
      
      final response = await _supabase
          .from('temuan')
          .insert(temuan.toJson())
          .select()
          .single();

      print('✅ Data berhasil disimpan: $response');
      
      return {
        'success': true,
        'data': TemuanModel.fromJson(response),
        'message': 'Data temuan berhasil disimpan!'
      };
    } catch (e) {
      print('❌ Error di createTemuanSilent: $e');
      
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Gagal menyimpan data: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> getAllTemuan({BuildContext? context}) async {
    return {
      'success': false,
      'message': 'Not implemented',
      'data': null
    };
  }
}
