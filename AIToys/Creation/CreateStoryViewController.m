//
//  CreateStoryViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import "CreateStoryViewController.h"
#import <Speech/Speech.h>
#import <Photos/Photos.h>

@interface CreateStoryViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// UI Components
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

// Story Theme
@property (nonatomic, strong) UILabel *themeLabel;
@property (nonatomic, strong) UITextField *themeTextField;
@property (nonatomic, strong) UILabel *themeCharCountLabel;

// Story Illustration
@property (nonatomic, strong) UILabel *illustrationLabel;
@property (nonatomic, strong) UIButton *addImageButton;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UILabel *imageHintLabel;

// Story Content
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *voiceInputButton;
@property (nonatomic, strong) UILabel *contentCharCountLabel;

// Story Type
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIButton *typeButton;

// Story's Protagonist
@property (nonatomic, strong) UILabel *protagonistLabel;
@property (nonatomic, strong) UITextField *protagonistTextField;

// Story Length
@property (nonatomic, strong) UILabel *lengthLabel;
@property (nonatomic, strong) UIButton *lengthButton;

// Bottom Button
@property (nonatomic, strong) UIButton *nextButton;

// Data
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, copy) NSString *selectedType;
@property (nonatomic, copy) NSString *selectedLength;

// Speech Recognition
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

@end

@implementation CreateStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Create Story";
    
    [self setupUI];
    [self setupSpeechRecognition];
    
    // 添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    // ScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    // Story Theme
    [self setupThemeSection];
    
    // Story Illustration
    [self setupIllustrationSection];
    
    // Story Content
    [self setupContentSection];
    
    // Story Type
    [self setupTypeSection];
    
    // Story's Protagonist
    [self setupProtagonistSection];
    
    // Story Length
    [self setupLengthSection];
    
    // Next Button
    [self setupNextButton];
    
    [self setupConstraints];
}

- (void)setupThemeSection {
    self.themeLabel = [[UILabel alloc] init];
    self.themeLabel.text = @"Story Theme";
    self.themeLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.themeLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.themeLabel];
    
    self.themeTextField = [[UITextField alloc] init];
    self.themeTextField.placeholder = @"Please Input,不超过120字符";
    self.themeTextField.font = [UIFont systemFontOfSize:15];
    self.themeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.themeTextField.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    self.themeTextField.layer.cornerRadius = 8;
    self.themeTextField.layer.borderWidth = 0;
    self.themeTextField.delegate = self;
    [self.themeTextField addTarget:self action:@selector(themeTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.themeTextField];
    
    self.themeCharCountLabel = [[UILabel alloc] init];
    self.themeCharCountLabel.text = @"0/120";
    self.themeCharCountLabel.font = [UIFont systemFontOfSize:12];
    self.themeCharCountLabel.textColor = [UIColor systemGrayColor];
    self.themeCharCountLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.themeCharCountLabel];
}

- (void)setupIllustrationSection {
    self.illustrationLabel = [[UILabel alloc] init];
    self.illustrationLabel.text = @"Story 插图";
    self.illustrationLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.illustrationLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.illustrationLabel];
    
    self.addImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addImageButton.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    self.addImageButton.layer.cornerRadius = 8;
    [self.addImageButton addTarget:self action:@selector(addImageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addImageButton];
    
    UIImageView *plusIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"plus"]];
    plusIcon.tintColor = [UIColor systemGrayColor];
    plusIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addImageButton addSubview:plusIcon];
    
    UILabel *addLabel = [[UILabel alloc] init];
    addLabel.text = @"添加图片";
    addLabel.font = [UIFont systemFontOfSize:14];
    addLabel.textColor = [UIColor systemGrayColor];
    addLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addImageButton addSubview:addLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [plusIcon.centerXAnchor constraintEqualToAnchor:self.addImageButton.centerXAnchor],
        [plusIcon.topAnchor constraintEqualToAnchor:self.addImageButton.topAnchor constant:20],
        [plusIcon.widthAnchor constraintEqualToConstant:40],
        [plusIcon.heightAnchor constraintEqualToConstant:40],
        
        [addLabel.centerXAnchor constraintEqualToAnchor:self.addImageButton.centerXAnchor],
        [addLabel.topAnchor constraintEqualToAnchor:plusIcon.bottomAnchor constant:8]
    ]];
    
    self.imageHintLabel = [[UILabel alloc] init];
    self.imageHintLabel.text = @"只能选择图库图片";
    self.imageHintLabel.font = [UIFont systemFontOfSize:12];
    self.imageHintLabel.textColor = [UIColor systemRedColor];
    [self.contentView addSubview:self.imageHintLabel];
}

- (void)setupContentSection {
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.text = @"Story Content";
    self.contentLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.contentLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.contentLabel];
    
    self.contentTextView = [[UITextView alloc] init];
    self.contentTextView.font = [UIFont systemFontOfSize:15];
    self.contentTextView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    self.contentTextView.layer.cornerRadius = 8;
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(12, 8, 12, 8);
    self.contentTextView.delegate = self;
    [self.contentView addSubview:self.contentTextView];
    
    // Placeholder
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.text = @"Please Input";
    placeholderLabel.font = [UIFont systemFontOfSize:15];
    placeholderLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    placeholderLabel.tag = 999;
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentTextView addSubview:placeholderLabel];
    [NSLayoutConstraint activateConstraints:@[
        [placeholderLabel.topAnchor constraintEqualToAnchor:self.contentTextView.topAnchor constant:12],
        [placeholderLabel.leadingAnchor constraintEqualToAnchor:self.contentTextView.leadingAnchor constant:12]
    ]];
    
    // Voice Input Button
    self.voiceInputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceInputButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
    self.voiceInputButton.tintColor = [UIColor systemGrayColor];
    [self.voiceInputButton addTarget:self action:@selector(voiceInputButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.voiceInputButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentTextView addSubview:self.voiceInputButton];
    
    self.contentCharCountLabel = [[UILabel alloc] init];
    self.contentCharCountLabel.text = @"0/2400";
    self.contentCharCountLabel.font = [UIFont systemFontOfSize:12];
    self.contentCharCountLabel.textColor = [UIColor systemGrayColor];
    self.contentCharCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentTextView addSubview:self.contentCharCountLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.voiceInputButton.trailingAnchor constraintEqualToAnchor:self.contentTextView.trailingAnchor constant:-12],
        [self.voiceInputButton.bottomAnchor constraintEqualToAnchor:self.contentTextView.bottomAnchor constant:-12],
        [self.voiceInputButton.widthAnchor constraintEqualToConstant:24],
        [self.voiceInputButton.heightAnchor constraintEqualToConstant:24],
        
        [self.contentCharCountLabel.trailingAnchor constraintEqualToAnchor:self.voiceInputButton.leadingAnchor constant:-8],
        [self.contentCharCountLabel.centerYAnchor constraintEqualToAnchor:self.voiceInputButton.centerYAnchor]
    ]];
}

- (void)setupTypeSection {
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.text = @"Story Type";
    self.typeLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.typeLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.typeLabel];
    
    self.typeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.typeButton setTitle:@"Please Select" forState:UIControlStateNormal];
    [self.typeButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateNormal];
    self.typeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.typeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.typeButton.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    self.typeButton.layer.cornerRadius = 8;
    [self.typeButton addTarget:self action:@selector(typeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    chevron.tintColor = [UIColor systemGrayColor];
    chevron.translatesAutoresizingMaskIntoConstraints = NO;
    [self.typeButton addSubview:chevron];
    [NSLayoutConstraint activateConstraints:@[
        [chevron.trailingAnchor constraintEqualToAnchor:self.typeButton.trailingAnchor constant:-12],
        [chevron.centerYAnchor constraintEqualToAnchor:self.typeButton.centerYAnchor]
    ]];
    
    [self.contentView addSubview:self.typeButton];
}

- (void)setupProtagonistSection {
    self.protagonistLabel = [[UILabel alloc] init];
    self.protagonistLabel.text = @"Story's Protagonist";
    self.protagonistLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.protagonistLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.protagonistLabel];
    
    self.protagonistTextField = [[UITextField alloc] init];
    self.protagonistTextField.placeholder = @"Please Input";
    self.protagonistTextField.font = [UIFont systemFontOfSize:15];
    self.protagonistTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.protagonistTextField.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    self.protagonistTextField.layer.cornerRadius = 8;
    self.protagonistTextField.layer.borderWidth = 0;
    [self.contentView addSubview:self.protagonistTextField];
}

- (void)setupLengthSection {
    self.lengthLabel = [[UILabel alloc] init];
    self.lengthLabel.text = @"Story Length";
    self.lengthLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.lengthLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.lengthLabel];
    
    self.lengthButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.lengthButton setTitle:@"Please Select" forState:UIControlStateNormal];
    [self.lengthButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateNormal];
    self.lengthButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.lengthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.lengthButton.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    self.lengthButton.layer.cornerRadius = 8;
    [self.lengthButton addTarget:self action:@selector(lengthButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    chevron.tintColor = [UIColor systemGrayColor];
    chevron.translatesAutoresizingMaskIntoConstraints = NO;
    [self.lengthButton addSubview:chevron];
    [NSLayoutConstraint activateConstraints:@[
        [chevron.trailingAnchor constraintEqualToAnchor:self.lengthButton.trailingAnchor constant:-12],
        [chevron.centerYAnchor constraintEqualToAnchor:self.lengthButton.centerYAnchor]
    ]];
    
    [self.contentView addSubview:self.lengthButton];
}

- (void)setupNextButton {
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setTitle:@"Next Step" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.nextButton.backgroundColor = [UIColor systemBlueColor];
    self.nextButton.layer.cornerRadius = 25;
    [self.nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
}

- (void)setupConstraints {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.themeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.themeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.themeCharCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.illustrationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.addImageButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.typeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.protagonistLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.protagonistTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.lengthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.lengthButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // ScrollView
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-80],
        
        // ContentView
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        
        // Theme
        [self.themeLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
        [self.themeLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        
        [self.themeTextField.topAnchor constraintEqualToAnchor:self.themeLabel.bottomAnchor constant:12],
        [self.themeTextField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.themeTextField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.themeTextField.heightAnchor constraintEqualToConstant:44],
        
        [self.themeCharCountLabel.topAnchor constraintEqualToAnchor:self.themeTextField.bottomAnchor constant:4],
        [self.themeCharCountLabel.trailingAnchor constraintEqualToAnchor:self.themeTextField.trailingAnchor],
        
        // Illustration
        [self.illustrationLabel.topAnchor constraintEqualToAnchor:self.themeCharCountLabel.bottomAnchor constant:24],
        [self.illustrationLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        
        [self.addImageButton.topAnchor constraintEqualToAnchor:self.illustrationLabel.bottomAnchor constant:12],
        [self.addImageButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.addImageButton.widthAnchor constraintEqualToConstant:120],
        [self.addImageButton.heightAnchor constraintEqualToConstant:120],
        
        [self.imageHintLabel.leadingAnchor constraintEqualToAnchor:self.addImageButton.trailingAnchor constant:12],
        [self.imageHintLabel.centerYAnchor constraintEqualToAnchor:self.addImageButton.centerYAnchor],
        
        // Content
        [self.contentLabel.topAnchor constraintEqualToAnchor:self.addImageButton.bottomAnchor constant:24],
        [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        
        [self.contentTextView.topAnchor constraintEqualToAnchor:self.contentLabel.bottomAnchor constant:12],
        [self.contentTextView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.contentTextView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.contentTextView.heightAnchor constraintEqualToConstant:200],
        
        // Type
        [self.typeLabel.topAnchor constraintEqualToAnchor:self.contentTextView.bottomAnchor constant:24],
        [self.typeLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        
        [self.typeButton.topAnchor constraintEqualToAnchor:self.typeLabel.bottomAnchor constant:12],
        [self.typeButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.typeButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.typeButton.heightAnchor constraintEqualToConstant:44],
        
        // Protagonist
        [self.protagonistLabel.topAnchor constraintEqualToAnchor:self.typeButton.bottomAnchor constant:24],
        [self.protagonistLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        
        [self.protagonistTextField.topAnchor constraintEqualToAnchor:self.protagonistLabel.bottomAnchor constant:12],
        [self.protagonistTextField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.protagonistTextField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.protagonistTextField.heightAnchor constraintEqualToConstant:44],
        
        // Length
        [self.lengthLabel.topAnchor constraintEqualToAnchor:self.protagonistTextField.bottomAnchor constant:24],
        [self.lengthLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        
        [self.lengthButton.topAnchor constraintEqualToAnchor:self.lengthLabel.bottomAnchor constant:12],
        [self.lengthButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.lengthButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.lengthButton.heightAnchor constraintEqualToConstant:44],
        [self.lengthButton.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-30],
        
        // Next Button
        [self.nextButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.nextButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.nextButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.nextButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

#pragma mark - Actions

- (void)themeTextChanged:(UITextField *)textField {
    NSInteger length = textField.text.length;
    if (length > 120) {
        textField.text = [textField.text substringToIndex:120];
        length = 120;
    }
    self.themeCharCountLabel.text = [NSString stringWithFormat:@"%ld/120", (long)length];
}

- (void)addImageButtonTapped {
    [self.view endEditing:YES];
    
    // 检查相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showImagePicker];
                });
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self showImagePicker];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"需要相册权限"
                                                                       message:@"请在设置中开启相册访问权限"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)showImagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)voiceInputButtonTapped {
    [self.view endEditing:YES];
    
    if (self.audioEngine.isRunning) {
        [self stopRecording];
    } else {
        [self startRecording];
    }
}

- (void)typeButtonTapped {
    [self.view endEditing:YES];
    
    NSArray *types = @[@"童话", @"寓言", @"冒险", @"超级英雄", @"科幻", @"教育", @"睡前故事"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择故事类型"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *type in types) {
        [alert addAction:[UIAlertAction actionWithTitle:type
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            self.selectedType = type;
            [self.typeButton setTitle:type forState:UIControlStateNormal];
            [self.typeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.typeButton;
        alert.popoverPresentationController.sourceRect = self.typeButton.bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)lengthButtonTapped {
    [self.view endEditing:YES];
    
    NSArray *lengths = @[@"1.5min", @"3min", @"4.5min", @"6min"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择故事长度"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *length in lengths) {
        [alert addAction:[UIAlertAction actionWithTitle:length
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            self.selectedLength = length;
            [self.lengthButton setTitle:length forState:UIControlStateNormal];
            [self.lengthButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.lengthButton;
        alert.popoverPresentationController.sourceRect = self.lengthButton.bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)nextButtonTapped {
    // 验证表单
    if (self.themeTextField.text.length == 0) {
        [self showAlertWithMessage:@"请输入故事主题"];
        return;
    }
    
    if (!self.selectedImage) {
        [self showAlertWithMessage:@"请选择故事插图"];
        return;
    }
    
    if (self.contentTextView.text.length == 0) {
        [self showAlertWithMessage:@"请输入故事内容"];
        return;
    }
    
    if (!self.selectedType) {
        [self showAlertWithMessage:@"请选择故事类型"];
        return;
    }
    
    if (self.protagonistTextField.text.length == 0) {
        [self showAlertWithMessage:@"请输入主角名称"];
        return;
    }
    
    if (!self.selectedLength) {
        [self showAlertWithMessage:@"请选择故事长度"];
        return;
    }
    
    // TODO: 提交数据到下一步
    NSLog(@"所有数据验证通过，准备提交");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提交成功"
                                                                   message:@"进入下一步：选择声音"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.themeTextField) {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return newText.length <= 120;
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    // 更新占位符
    UILabel *placeholderLabel = [textView viewWithTag:999];
    placeholderLabel.hidden = textView.text.length > 0;
    
    // 更新字数统计
    NSInteger length = textView.text.length;
    if (length > 2400) {
        textView.text = [textView.text substringToIndex:2400];
        length = 2400;
    }
    self.contentCharCountLabel.text = [NSString stringWithFormat:@"%ld/2400", (long)length];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.selectedImage = image;
    
    // 显示选中的图片
    if (!self.selectedImageView) {
        self.selectedImageView = [[UIImageView alloc] init];
        self.selectedImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.selectedImageView.clipsToBounds = YES;
        self.selectedImageView.layer.cornerRadius = 8;
        [self.addImageButton addSubview:self.selectedImageView];
        
        self.selectedImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.selectedImageView.topAnchor constraintEqualToAnchor:self.addImageButton.topAnchor],
            [self.selectedImageView.leadingAnchor constraintEqualToAnchor:self.addImageButton.leadingAnchor],
            [self.selectedImageView.trailingAnchor constraintEqualToAnchor:self.addImageButton.trailingAnchor],
            [self.selectedImageView.bottomAnchor constraintEqualToAnchor:self.addImageButton.bottomAnchor]
        ]];
    }
    
    self.selectedImageView.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Speech Recognition

- (void)setupSpeechRecognition {
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    self.audioEngine = [[AVAudioEngine alloc] init];
}

- (void)startRecording {
    // 请求语音识别权限
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                [self performRecording];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"需要语音识别权限"
                                                                               message:@"请在设置中开启语音识别权限"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

- (void)performRecording {
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:0 error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    self.recognitionRequest.shouldReportPartialResults = YES;
    
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (result) {
            self.contentTextView.text = [self.contentTextView.text stringByAppendingString:result.bestTranscription.formattedString];
            [self textViewDidChange:self.contentTextView];
        }
        
        if (error || result.isFinal) {
            [self stopRecording];
        }
    }];
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    
    [self.voiceInputButton setImage:[UIImage systemImageNamed:@"mic.fill.badge.plus"] forState:UIControlStateNormal];
    self.voiceInputButton.tintColor = [UIColor systemRedColor];
}

- (void)stopRecording {
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    [self.audioEngine.inputNode removeTapOnBus:0];
    
    self.recognitionRequest = nil;
    self.recognitionTask = nil;
    
    [self.voiceInputButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
    self.voiceInputButton.tintColor = [UIColor systemGrayColor];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

@end
