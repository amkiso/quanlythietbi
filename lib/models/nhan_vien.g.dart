// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nhan_vien.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NhanVien _$NhanVienFromJson(Map<String, dynamic> json) => NhanVien(
  nhanVienId: (json['nhanVienId'] as num?)?.toInt(),
  maNhanVien: json['maNhanVien'] as String,
  hoTen: json['hoTen'] as String,
  taiKhoan: json['taiKhoan'] as String,
  matKhau: json['matKhau'] as String?,
  vaiTroId: (json['vaiTroId'] as num).toInt(),
  khoId: (json['khoId'] as num).toInt(),
  trangThaiId: (json['trangThaiId'] as num).toInt(),
);

Map<String, dynamic> _$NhanVienToJson(NhanVien instance) => <String, dynamic>{
  'nhanVienId': instance.nhanVienId,
  'maNhanVien': instance.maNhanVien,
  'hoTen': instance.hoTen,
  'taiKhoan': instance.taiKhoan,
  'matKhau': instance.matKhau,
  'vaiTroId': instance.vaiTroId,
  'khoId': instance.khoId,
  'trangThaiId': instance.trangThaiId,
};
