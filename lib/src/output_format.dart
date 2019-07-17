class OutputFormat {
  static const DEFAULT = 0;

  /// 3GPP media file format*/
  static const THREE_GPP = 1;

  /// MPEG4 media file format*/
  static const MPEG_4 = 2;

  /** The following formats are audio only .aac or .amr formats */

  /// AMR NB file format */
  static const AMR_NB = 3;

  /// AMR WB file format */
  static const AMR_WB = 4;

  /// AAC ADTS file format */
  static const AAC_ADTS = 6;

  /// H.264/AAC data encapsulated in MPEG2/TS */
  static const MPEG_2_TS = 8;

  /// VP8/VORBIS data in a WEBM container */
  static const WEBM = 9;
}
