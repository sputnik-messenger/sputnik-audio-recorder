#import "SputnikAudioRecorderPlugin.h"
#import <sputnik_audio_recorder/sputnik_audio_recorder-Swift.h>

@implementation SputnikAudioRecorderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSputnikAudioRecorderPlugin registerWithRegistrar:registrar];
}
@end
