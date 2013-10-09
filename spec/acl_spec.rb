require 'spec_helper'

describe SimpleAcl::Acl do
  let(:role_1){
    {privileges: {create: true}}
  }
  let(:role_2){
    {privileges: {create: false}}
  }
  let(:role_4){
    {inherit: :role_1}
  }

  before do
    SimpleAcl::Configuration.authorized_roles += [:role_1, :role_2, :role_3, :role_4]
  end

  describe "#check_acl" do
    subject {@acl.check_acl(@current_role, @action, @values)}

    context "role_1 only, has create privileges" do
      before do
        @acl = SimpleAcl::Acl.new
        @acl.configuration.add_role(:role_1, role_1)
        @acl.configuration.add_role(:role_2, role_2)
        @acl.configuration.add_role(:role_4, role_4)
        @action = :create
        @values = 'dummy'
      end

      context "with role1" do
        before do
          @current_role = :role_1
        end
        it "role_1 can create" do
          expect(subject).to be_true
        end
      end

      context "with role4" do
        before do
          @current_role = :role_4
        end
        it "role_4 can create" do
          expect(subject).to be_true
        end
      end

      context "with role2" do
        before do
          @current_role = :role_2
        end
        it "role_2 cannot create" do
          expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end

      context "with role3" do
        before do
          @current_role = :role_3
        end
        it "role_3 cannot create" do
          expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end
    end

    context "role_1 only, has a custom assertion on create" do
      before do
        @acl = SimpleAcl::Acl.new
        @acl.configuration.add_role(:role_1,
                                    {privileges:
                                       {
                                         create: lambda{|current_role, values| values[:id] == 99}
                                       }
                                    }
        )
        @acl.configuration.add_role(:role_2, role_2)
        @acl.configuration.add_role(:role_4, role_4)
        @action = :create
        @current_role = :role_1
        @values = {id: 99}
      end

      context "with value id == 99" do

        context "with role1" do
          before do
            @current_role = :role_1
          end
          it "role_1 can create" do
            expect(subject).to be_true
          end
        end

        context "with role4" do
          before do
            @current_role = :role_4
          end
          it "role_4 can create" do
            expect(subject).to be_true
          end
        end

        context "with role2" do
          before do
            @current_role = :role_2
          end
          it "role_2 cannot create" do
            expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
          end
        end

        context "with role3" do
          before do
            @current_role = :role_3
          end
          it "role_3 cannot create" do
            expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
          end
        end
      end

      context "with value id != 99" do

        context "with role1" do
          before do
            @current_role = :role_1
          end
          it "role_1 can create" do
            expect(subject).to be_true
          end
        end

        context "with role4" do
          before do
            @current_role = :role_4
          end
          it "role_4 can create" do
            expect(subject).to be_true
          end
        end

        context "with role2" do
          before do
            @current_role = :role_2
          end
          it "role_2 cannot create" do
            expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
          end
        end

        context "with role3" do
          before do
            @current_role = :role_3
          end
          it "role_3 cannot create" do
            expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
          end
        end
      end
    end

  end

  describe "#assert" do

  end

end
