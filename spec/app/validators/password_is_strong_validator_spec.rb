require 'spec_helper'

describe PasswordIsStrongValidator do
  subject(:password_is_strong_validator) do
    described_class.new(
        :attributes => attributes
    )
  end

  let(:attribute) do
    :password
  end

  let(:attributes) do
    [
        attribute
    ]
  end

  context '#contains_repetition' do
    subject(:contains_repetition?) do
      password_is_strong_validator.send(:contains_repetition?, password)
    end

    context 'with all the same character' do
      let(:password) do
        'aaaaa'
      end

      it { should be_true }
    end

    context 'with repeats of 2 characters' do
      let(:password) do
        'abab'
      end

      it { should be_true }
    end

    context 'with repeats of 3 characters' do
      let(:password) do
        'abcabc'
      end

      it { should be_true }
    end

    context 'with repeats of 4 characters' do
      let(:password) do
        'abcdabcd'
      end

      it { should be_true }
    end

    context 'without any repeats' do
      let(:password) do
        'abcdefgh'
      end

      it { should be_false }
    end
  end

  context '#contains_username?' do
    subject(:contains_username?) do
      password_is_strong_validator.send(:contains_username?, username, password)
    end

    let(:username) do
      ''
    end

    context 'with blank password' do
      let(:password) do
        ''
      end

      it { should be_false }
    end

    context 'without blank password' do
      let(:password) do
        'password'
      end

      context 'with blank username' do
        let(:username) do
          ''
        end

        it { should be_false }
      end

      context 'without blank username' do
        let(:username) do
          'username'
        end

        it 'should escape username' do
          Regexp.should_receive(:escape).with(username).and_call_original

          contains_username?
        end

        context 'with matching password' do
          context 'of different case' do
            let(:password) do
              username.titleize
            end

            it { should be_true }
          end

          context 'of same case' do
            let(:password) do
              username
            end

            it { should be_true }
          end
        end
      end
    end
  end

  context '#validate_each' do
    subject(:validate_each) do
      password_is_strong_validator.validate_each(record, attribute, value)
    end

    let(:record) do
      record_class.new
    end

    let(:record_class) do
      attribute = self.attribute

      Class.new do
        include ActiveModel::Validations

        #
        # Attributes
        #

        # @!attribute [rw] username
        #   User name
        #
        #   @return [String]
        attr_accessor :username

        #
        # Validations
        #

        validates attribute,
                  :password_is_strong => true
      end
    end

    context 'with blank' do
      let(:value) do
        ''
      end

      it 'should not record any error' do
        validate_each

        record.errors.should be_empty
      end
    end

    context 'without blank' do
      context 'with simple' do
        let(:value) do
          'a'
        end

        it 'should record error on attributes' do
          validate_each

          record.errors[attribute].should include('must contain letters, numbers, and at least one special character')
        end
      end

      context 'without simple' do
        context 'contains username' do
          let(:username) do
            'root'
          end

          let(:value) do
            username
          end

          before(:each) do
            record.username = username
          end

          it 'should record error on attribute' do
            validate_each

            record.errors[attribute].should include('must not contain the username')
          end
        end

        context 'does not contain username' do
          context 'with password in COMMON_PASSWORDS' do
            let(:value) do
              described_class::COMMON_PASSWORDS.sample
            end

            it 'should record error on attribute' do
              validate_each

              record.errors[attribute].should include('must not be a common password')
            end
          end

          context 'without password in COMMON_PASSWORDS' do
            context 'with repetition' do
              let(:value) do
                'aaaaa'
              end

              it 'should record error on attribute' do
                validate_each

                record.errors[attribute].should include('must not be a predictable sequence of characters')
              end
            end

            context 'without repetition' do
              let(:value) do
                'A$uperg00dp@ssw0rd'
              end

              it 'should not record any errors' do
                validate_each

                record.errors.should be_empty
              end
            end
          end
        end
      end
    end
  end
end