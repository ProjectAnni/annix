/**
 * // initialize Anniv
 * Global.anniv = await AnnivController.create(
 *   url: _urlController.text,
 *   email: _emailController.text,
 *   password: _passwordController.text,
 * );
 * // initialize metadata source
 * if (_databasePath == null) {
 *   // use Anniv as metadata source
 *   Global.metadataSource = AnnivMetadataSource();
 * } else {
 *   // use database as metadata source
 *   if (_databasePath!.startsWith('http')) {
 *     // TODO: Download from URL
 *     throw UnimplementedError();
 *   }
 *   final metadataSource = SqliteMetadataSource(dbPath: _databasePath!);
 *   await metadataSource.prepare();
 *   // TODO: validate database
 *   // TODO: persist database path
 *   Global.metadataSource = metadataSource;
 * }
 */