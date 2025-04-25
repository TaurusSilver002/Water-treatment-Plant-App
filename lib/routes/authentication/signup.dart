import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:waterplant/bloc/register/registrationBloc.dart';
import 'package:waterplant/config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterplant/models/auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late RegistrationBloc _registrationBloc;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  int? _selectedRoleId;
  String? _selectedQualification;
  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedDate;

  final List<String> _qualifications = [
    'High School',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Diploma',
    'Other'
  ];

  final List<Map<String, dynamic>> _roles = [
    {'id': 3, 'name': 'Client'},
    {'id': 2, 'name': 'Operator'},
  ];

  @override
  void initState() {
    super.initState();
    _registrationBloc = RegistrationBloc(GetIt.I<AuthRepo>());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _registrationBloc,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            title: const Text('Sign Up'),
            centerTitle: true,
            backgroundColor: AppColors.darkblue,
            foregroundColor: AppColors.cream,
          ),
          body: Form(
            key: _formKey,
            child: Stepper(
              elevation: 0,
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                bool isLastStep = _currentStep == 3;
                if (isLastStep) {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedRoleId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select a role')),
                      );
                      return;
                    }
                    _handleSignUp(context);
                  }
                } else {
                  bool canProceed = false;
                  switch (_currentStep) {
                    case 0:
                      canProceed = _validateBasicInfo();
                      break;
                    case 1:
                      canProceed = _validateSecurity();
                      break;
                    case 2:
                      canProceed = _validatePersonalDetails();
                      break;
                    default:
                      canProceed = true;
                  }
                  if (canProceed) {
                    setState(() {
                      _currentStep += 1;
                    });
                  } else {
                    _formKey.currentState?.validate();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: _buildSteps(),
              controlsBuilder: (context, details) {
                return BlocListener<RegistrationBloc, RegistrationState>(
                  listener: (context, state) {
                    if (state is RegistrationLoadingState) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is RegistrationSuccessState) {
                      Navigator.pop(context); // Close loading dialog
                      Navigator.pushReplacementNamed(context, '/home');
                    } else if (state is RegistrationFailedState) {
                      Navigator.pop(context); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_currentStep == 3) {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedRoleId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please select a role')),
                                  );
                                  return;
                                }
                                _handleSignUp(context);
                              }
                            } else {
                              details.onStepContinue?.call();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkblue,
                            foregroundColor: AppColors.cream,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(_currentStep == 3 ? 'Sign Up' : 'Continue'),
                        ),
                        if (_currentStep > 0) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Login',
                      style: TextStyle(color: AppColors.darkblue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        state: _getStepState(0),
        isActive: _currentStep >= 0,
        title: const Text('Basic Information'),
        content: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        state: _getStepState(1),
        isActive: _currentStep >= 1,
        title: const Text('Security'),
        content: Column(
          children: [
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        state: _getStepState(2),
        isActive: _currentStep >= 2,
        title: const Text('Personal Details'),
        content: Column(
          children: [
            TextFormField(
              controller: _aadharController,
              decoration: const InputDecoration(
                labelText: 'Aadhar Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              maxLength: 12,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Aadhar number';
                }
                if (value.length != 12 ||
                    !RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Please enter a valid 12-digit Aadhar number';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                    _dobController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your date of birth';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        state: _getStepState(3),
        isActive: _currentStep >= 3,
        title: const Text('Additional Information'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Qualification',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              value: _selectedQualification,
              items: _qualifications.map((String qualification) {
                return DropdownMenuItem<String>(
                  value: qualification,
                  child: Text(qualification),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedQualification = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your qualification';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Select your role:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: _roles.map((role) {
                return RadioListTile<int>(
                  title: Text(role['name']),
                  value: role['id'],
                  groupValue: _selectedRoleId,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedRoleId = value;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ];
  }

  StepState _getStepState(int step) {
    if (_currentStep > step) {
      return StepState.complete;
    } else if (_currentStep == step) {
      switch (step) {
        case 0:
          return _validateBasicInfo() ? StepState.indexed : StepState.error;
        case 1:
          return _validateSecurity() ? StepState.indexed : StepState.error;
        case 2:
          return _validatePersonalDetails()
              ? StepState.indexed
              : StepState.error;
        case 3:
          return _validateAdditionalInfo()
              ? StepState.indexed
              : StepState.error;
        default:
          return StepState.indexed;
      }
    }
    return StepState.indexed;
  }

  bool _validateBasicInfo() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text)) {
      return false;
    }
    return true;
  }

  bool _validateSecurity() {
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6 ||
        _confirmPasswordController.text != _passwordController.text) {
      return false;
    }
    return true;
  }

  bool _validatePersonalDetails() {
    if (_aadharController.text.isEmpty ||
        !RegExp(r'^[0-9]{12}$').hasMatch(_aadharController.text) ||
        _phoneController.text.isEmpty ||
        !RegExp(r'^[0-9]{10}$').hasMatch(_phoneController.text) ||
        _dobController.text.isEmpty) {
      return false;
    }
    return true;
  }

  bool _validateAdditionalInfo() {
    if (_addressController.text.isEmpty ||
        _selectedQualification == null ||
        _selectedRoleId == null) {
      return false;
    }
    return true;
  }

  void _handleSignUp(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final registrationEvent = RegistrationCreateUserEvent(
        email: _emailController.text,
        password: _passwordController.text,
        firstname: _firstNameController.text,
        lastname: _lastNameController.text,
        aadharNumber: _aadharController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        dateOfBirth: _dobController.text,
        qualification: _selectedQualification!,
        roleId: _selectedRoleId!,
      );

      context.read<RegistrationBloc>().add(registrationEvent);
    }
  }

  @override
  void dispose() {
    _registrationBloc.close();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _aadharController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
